# Building an End-to-End MLOps Pipeline: Hotel Booking Cancellation Prediction

This comprehensive guide walks through building a production-ready machine learning pipeline for hotel booking cancellation prediction, following a structured MLOps workflow.

## MLOps Workflow Steps

1. [Database Setup](#database-setup)
2. [Project Setup](#project-setup)
3. [Data Ingestion](#data-ingestion)
4. [Jupyter Notebook Testing](#jupyter-notebook-testing)
5. [Data Processing](#data-processing)
6. [Model Training](#model-training)
7. [Experiment Tracking](#experiment-tracking)
8. [Training Pipeline](#training-pipeline)
9. [Data Versioning](#data-versioning)
10. [Code Versioning](#code-versioning)
11. [User App Building](#user-app-building)
12. [CI-CD Deployment](#ci-cd-deployment)

## Database Setup

We leverage Google Cloud Platform (GCP) for our database infrastructure, providing a scalable and reliable storage solution for our MLOps pipeline. The setup includes:

### Google Cloud Storage
- Used for storing raw and processed datasets
- Enables versioning and access control
- Provides high durability and availability

### BigQuery Integration
- Enables efficient querying of large datasets
- Supports data analysis and feature engineering
- Seamless integration with other GCP services

### Setup Steps:

1. Create a GCP Project and enable required APIs:
```bash
# Enable required GCP services
gcloud services enable storage.googleapis.com bigquery.googleapis.com
```

2. Configure Google Cloud Storage bucket:
```bash
# Create storage bucket for datasets
gcloud storage buckets create gs://hotel-booking-mlops-data \
    --location=us-central1 \
    --uniform-bucket-level-access
```

3. Set up BigQuery dataset:
```bash
# Create BigQuery dataset
bq mk --dataset \
    --description "Hotel Booking MLOps Dataset" \
    --location us-central1 \
    hotel_booking_mlops
```

4. Configure authentication:
```bash
# Set up application default credentials
gcloud auth application-default login
```

Our Python code uses the Google Cloud client libraries to interact with these services:

```python
from google.cloud import storage
from google.cloud import bigquery

def setup_gcp_storage():
    storage_client = storage.Client()
    bucket = storage_client.bucket('hotel-booking-mlops-data')
    return bucket

def setup_bigquery():
    client = bigquery.Client()
    dataset_ref = client.dataset('hotel_booking_mlops')
    return client, dataset_ref
```

The GCP infrastructure provides:
- Scalable data storage
- Automated backups
- Data versioning
- Access control and security
- Integration with CI/CD pipeline

## Project Setup

The project follows a clean, modular structure:

```
Project-1/
├── src/                    # Core ML components
├── config/                 # Configuration management
├── pipeline/              # Training pipelines
├── artifacts/             # Model & data artifacts
├── templates/             # Web UI templates
└── static/                # UI assets
```

## Data Ingestion

The data ingestion pipeline (`src/data_ingestion.py`) handles:
- Raw data validation
- Train-test splitting
- Data storage management

```python
class DataIngestion:
    def __init__(self, config):
        self.config = config
        
    def run(self):
        # Ingest and validate raw data
        # Split into train/test
        # Save to artifacts/raw/
```

## Jupyter Notebook Testing

We maintain a notebook environment for:
- Exploratory Data Analysis (EDA)
- Feature importance analysis
- Model experimentation
- Performance visualization

Location: `notebook/notebook.ipynb`

## Data Processing

Data preprocessing pipeline (`src/data_preprocessing.py`) implements:
- Feature engineering
- Data cleaning
- Encoding & scaling
- SMOTE for imbalance handling

## Model Training

Model training (`src/model_training.py`) uses LightGBM with:
- Hyperparameter optimization
- Cross-validation
- Performance metrics tracking
- Model persistence

## Experiment Tracking

MLflow tracks all experiments:
- Model parameters
- Performance metrics
- Artifacts
- Training metadata

```python
with mlflow.start_run():
    mlflow.log_params(model_params)
    mlflow.log_metrics(metrics)
    mlflow.lightgbm.log_model(model, "model")
```

## Training Pipeline

The training pipeline (`pipeline/training_pipeline.py`) orchestrates:
- Data ingestion
- Preprocessing
- Model training
- Evaluation
- Artifact management

## Data Versioning

We maintain data versioning through:
- Raw data versioning
- Processed data versioning
- Train/test split versioning

## Code Versioning

Git handles code versioning with:
- Feature branches
- Version tags
- Release management

## User App Building

Flask web application (`application.py`) provides:
- REST API endpoints
- HTML interface
- ChatGPT integration for explanations
- Real-time predictions

```python
@app.route('/predict', methods=['POST'])
def predict():
    data = request.json
    prediction = model.predict(data)
    return jsonify({'prediction': prediction.tolist()})
```

## CI-CD Deployment

Deployment pipeline using Jenkins and Docker:
- Automated testing
- Docker image building
- Google Cloud Run deployment
- Continuous monitoring

### Jenkins Pipeline

```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'docker build -t hotel-pred .'
            }
        }
        stage('Deploy') {
            steps {
                sh 'gcloud run deploy hotel-pred --image gcr.io/${PROJECT_ID}/hotel-pred'
            }
        }
    }
}
```

### Docker Configuration

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY . .
RUN pip install -e .
EXPOSE 8080
CMD ["python", "application.py"]
```

## Project Dependencies

Key dependencies include:
- LightGBM for modeling
- MLflow for experiment tracking
- Flask for web service
- Docker for containerization
- Jenkins for CI/CD
- Google Cloud Run for deployment

## Getting Started

1. Clone the repository
2. Install dependencies:
   ```bash
   uv venv
   uv pip install -r requirements.txt
   ```
3. Configure environment variables
4. Run the training pipeline:
   ```bash
   python pipeline/training_pipeline.py
   ```
5. Start the web service:
   ```bash
   python application.py
   ```

## Monitoring and Maintenance

The system includes:
- Automated logging
- Performance monitoring
- Model retraining triggers
- Error tracking and alerting

For the complete implementation details and code, visit the [GitHub repository](https://github.com/AbulFaizBangi/MLOps-Project-1).

---

This MLOps pipeline demonstrates a complete machine learning lifecycle from data ingestion to production deployment, following industry best practices for maintainability, scalability, and reliability.

# Project Development Blog

## Navigation
- [Main Project Documentation](README.md)
- [Setup Guide](setup.md)
- [Notebook Documentation](notebook/notebook.md)