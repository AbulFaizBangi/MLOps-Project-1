# Hotel Booking Cancellation Prediction Project Setup Guide

## Prerequisites
- Python 3.11 or higher
- Docker installed
- Git installed
- GCP account (for deployment)
- Jenkins (for CI/CD)

## 1. Clone the Repository
```bash
git clone https://github.com/AbulFaizBangi/MLOps-Project-1.git
cd MLOps-Project-1
```

## 2. Python Environment Setup
```bash
# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: .\venv\Scripts\activate

# Install pip and upgrade it
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py
pip install --upgrade pip

# Install project dependencies
pip install uv
pip install -e .
```

## 3. Project Structure Setup
Ensure the following directory structure is in place:
```
Project-1/
├── artifacts/
│   ├── models/
│   ├── processed/
│   └── raw/
├── config/
│   ├── paths_config.py
│   └── model_params.py
├── logs/
├── notebooks/
├── pipeline/
├── src/
│   ├── data_ingestion.py
│   ├── data_preprocessing.py
│   ├── model_training.py
│   ├── logger.py
│   └── custom_exception.py
├── static/
├── templates/
├── tests/
└── application.py
```

## 4. Environment Variables
Create a .env file in the root directory:
```bash
LOG_DIR=logs
GCP_PROJECT=your-gcp-project-id
```

## 5. GCP Setup
1. Create a GCP project
2. Enable required APIs:
   - Cloud Run
   - Container Registry
   - Artifact Registry
3. Create a service account with necessary permissions
4. Download the service account key JSON file

## 6. Jenkins Setup
1. Install Jenkins custom Docker image:
```bash
cd custom_jenkins
docker build -t jenkins-dind .
docker run -p 8080:8080 -v jenkins_home:/var/jenkins_home jenkins-dind
```

2. Configure Jenkins credentials:
   - Add GitHub token
   - Add GCP service account key
   - Add DockerHub credentials

## 7. Docker Setup
1. Build the Docker image locally:
```bash
docker build -t ml-project:latest .
```

2. Test the Docker container:
```bash
docker run -p 8080:8080 ml-project:latest
```

## 8. MLflow Setup
```bash
# Install MLflow
pip install mlflow

# Start MLflow server
mlflow server --backend-store-uri sqlite:///mlflow.db --default-artifact-root ./artifacts/mlflow-artifacts --host 0.0.0.0
```

## 9. Running the Application

### Local Development
```bash
# Run the training pipeline
python pipeline/training_pipeline.py

# Start the Flask application
python application.py
```

### Using Docker
```bash
docker run -p 8080:8080 ml-project:latest
```

## 10. Running Tests
```bash
pytest tests/
```

## 11. CI/CD Pipeline
The Jenkins pipeline is configured to:
1. Clone the repository
2. Set up Python environment
3. Build Docker image
4. Push to GCR and DockerHub
5. Deploy to Cloud Run

Access the Jenkins dashboard and trigger the pipeline build.

## 12. Monitoring
- Logs are stored in the `logs/` directory
- MLflow tracking UI available at http://localhost:5000
- Application metrics accessible at http://localhost:8080

## 📚 Related Documentation
- [Main Project Documentation](README.md)
- [Project Blog](blog.md)
- [Notebook Documentation](notebook/notebook.md)

## Troubleshooting
1. If Docker build fails, check:
   - Dockerfile syntax
   - Required files presence
   - Network connectivity

2. If Jenkins pipeline fails:
   - Verify credentials
   - Check GCP permissions
   - Validate Jenkinsfile syntax

3. For application issues:
   - Check logs in logs/ directory
   - Verify model artifacts existence
   - Ensure all dependencies are installed