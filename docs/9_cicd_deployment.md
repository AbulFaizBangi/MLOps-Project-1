# CI/CD Deployment

## Overview
This document details the continuous integration and deployment setup using Jenkins and Docker for the Hotel Booking Prediction system.

## Table of Contents
1. [Jenkins Setup](#jenkins-setup)
2. [Docker Configuration](#docker-configuration)
3. [Pipeline Configuration](#pipeline-configuration)
4. [Deployment Strategy](#deployment-strategy)
5. [Monitoring](#monitoring)
6. [Security](#security)

## Jenkins Setup

### Custom Jenkins Docker Image
```dockerfile
# custom_jenkins/Dockerfile
FROM jenkins/jenkins:lts

USER root

# Install Docker
RUN apt-get update && \
    apt-get -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get -y install docker-ce docker-ce-cli containerd.io

# Install Python and pip
RUN apt-get install -y python3 python3-pip

# Add Jenkins user to Docker group
RUN usermod -aG docker jenkins

USER jenkins
```

### Jenkins Configuration
1. Create credentials:
   - GitHub token
   - Docker Hub credentials
   - GCP service account

2. Install plugins:
   - Docker Pipeline
   - GitHub Integration
   - Google Cloud SDK
   - Blue Ocean

## Docker Configuration

### Application Dockerfile
```dockerfile
# Dockerfile
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy requirements first for better caching
COPY pyproject.toml uv.lock ./

# Install dependencies
RUN pip install uv && \
    uv install && \
    rm -rf /root/.cache/pip

# Copy application code
COPY . .

# Set environment variables
ENV FLASK_APP=application.py
ENV FLASK_ENV=production
ENV PORT=8080

# Expose port
EXPOSE 8080

# Run the application
CMD ["python", "application.py"]
```

### Docker Compose
```yaml
# docker-compose.yml
version: '3'

services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      - GOOGLE_APPLICATION_CREDENTIALS=/app/config/service-account.json
    volumes:
      - ./logs:/app/logs
      - ./artifacts:/app/artifacts

  mlflow:
    image: mlflow
    ports:
      - "5000:5000"
    volumes:
      - ./mlruns:/mlruns
```

## Pipeline Configuration

### Jenkinsfile
```groovy
// Jenkinsfile
pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'hotel-booking-prediction'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        GCP_PROJECT = 'your-project-id'
        GCP_REGION = 'us-central1'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Test') {
            steps {
                sh '''
                    python -m pip install -e .
                    python -m pytest tests/
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                }
            }
        }

        stage('Push to Container Registry') {
            steps {
                script {
                    docker.withRegistry('https://gcr.io', 'gcr:credentials') {
                        docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}")
                            .push("gcr.io/${GCP_PROJECT}/${DOCKER_IMAGE}:${DOCKER_TAG}")
                    }
                }
            }
        }

        stage('Deploy to Cloud Run') {
            steps {
                sh """
                    gcloud run deploy ${DOCKER_IMAGE} \
                        --image gcr.io/${GCP_PROJECT}/${DOCKER_IMAGE}:${DOCKER_TAG} \
                        --platform managed \
                        --region ${GCP_REGION} \
                        --allow-unauthenticated
                """
            }
        }

        stage('Run Integration Tests') {
            steps {
                sh 'python tests/integration/test_api.py'
            }
        }

        stage('Monitor Deployment') {
            steps {
                sh """
                    gcloud run services describe ${DOCKER_IMAGE} \
                        --platform managed \
                        --region ${GCP_REGION} \
                        --format 'value(status.url)'
                """
            }
        }
    }

    post {
        success {
            slackSend(
                color: 'good',
                message: "Deployment successful: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
            )
        }
        failure {
            slackSend(
                color: 'danger',
                message: "Deployment failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
            )
        }
    }
}
```

## Deployment Strategy

### Continuous Deployment Flow
1. Code Push → GitHub
2. Jenkins Webhook Triggered
3. Run Tests
4. Build Docker Image
5. Push to Container Registry
6. Deploy to Cloud Run
7. Run Integration Tests
8. Monitor Deployment

### Rollback Strategy
```groovy
def rollback() {
    def previousTag = (env.BUILD_NUMBER.toInteger() - 1).toString()
    sh """
        gcloud run services update-traffic ${DOCKER_IMAGE} \
            --platform managed \
            --region ${GCP_REGION} \
            --to-revisions=${DOCKER_IMAGE}-${previousTag}=100
    """
}
```

## Monitoring

### Application Monitoring
```python
def setup_monitoring():
    """Configure monitoring for the application"""
    # Prometheus metrics
    metrics = PrometheusMetrics(app)
    
    # Request latency
    @metrics.histogram('request_latency_seconds',
                      'Request latency in seconds',
                      labels={'path': lambda: request.path})
    def latency():
        pass

    # Model prediction tracking
    @metrics.counter('model_predictions_total',
                    'Total number of model predictions',
                    labels={'result': lambda: 'success' if g.prediction_success else 'failure'})
    def track_predictions():
        pass
```

### Resource Monitoring
```yaml
# monitoring/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'flask-app'
    static_configs:
      - targets: ['localhost:8080']
    metrics_path: '/metrics'
```

## Security

### Docker Security
1. Use minimal base images
2. Run as non-root user
3. Scan for vulnerabilities
4. Use multi-stage builds

### Cloud Run Security
1. IAM roles and permissions
2. Secret management
3. Network security
4. HTTPS enforcement

### Environment Variables
```bash
# .env.prod
FLASK_ENV=production
GOOGLE_APPLICATION_CREDENTIALS=config/service-account.json
MODEL_PATH=artifacts/models/lgbm_model.pkl
```

## Testing

### Integration Tests
```python
def test_deployment():
    """Test deployed application"""
    response = requests.post(
        f"{CLOUD_RUN_URL}/api/predict",
        json={
            "lead_time": 45,
            "room_type": "Room_Type 1",
            "no_of_adults": 2
        }
    )
    assert response.status_code == 200
    assert "prediction" in response.json()
```

### Load Testing
```python
def load_test():
    """Run load tests on deployment"""
    locust_config = {
        'host': CLOUD_RUN_URL,
        'num_users': 100,
        'spawn_rate': 10,
        'run_time': '5m'
    }
    
    os.system(f"locust -f tests/load/locustfile.py --headless \
              -u {locust_config['num_users']} \
              -r {locust_config['spawn_rate']} \
              --run-time {locust_config['run_time']}")
```

## Troubleshooting Guide

1. Pipeline Failures
   - Check Jenkins logs
   - Verify Docker builds
   - Test GCP connectivity
   - Review test results

2. Deployment Issues
   - Check Cloud Run logs
   - Verify container health
   - Monitor resource usage
   - Test API endpoints

3. Security Problems
   - Review IAM permissions
   - Check SSL certificates
   - Scan for vulnerabilities
   - Monitor access logs