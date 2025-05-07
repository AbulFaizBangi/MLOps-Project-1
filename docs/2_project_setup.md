# Project Setup

## Overview
This document details the initial project setup, including repository structure, environment configuration, and dependency management using `uv`.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Repository Setup](#repository-setup)
3. [Project Structure](#project-structure)
4. [Environment Setup](#environment-setup)
5. [Configuration Files](#configuration-files)
6. [Development Tools](#development-tools)

## Prerequisites
- Python 3.11 or higher
- Git
- VS Code or similar IDE
- `uv` package manager

## Repository Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/AbulFaizBangi/MLOps-Project-1.git
   cd MLOps-Project-1
   ```

2. Initialize Git:
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   ```

## Project Structure
```
Project-1/
├── artifacts/              # Model and data artifacts
│   ├── models/            # Trained model files
│   ├── processed/         # Processed datasets
│   └── raw/              # Raw input data
├── config/                # Configuration files
│   ├── config.yaml       # Main configuration
│   ├── model_params.py   # Model hyperparameters
│   ├── paths_config.py   # File path configurations
│   └── gcp_config.py     # GCP configurations
├── docs/                  # Project documentation
├── logs/                  # Application logs
├── mlruns/               # MLflow tracking files
├── notebook/             # Jupyter notebooks
├── pipeline/             # Training pipelines
├── src/                  # Core source code
│   ├── data_ingestion.py
│   ├── data_preprocessing.py
│   ├── model_training.py
│   ├── logger.py
│   └── custom_exception.py
├── static/               # Static web assets
├── templates/            # Flask templates
├── tests/               # Test files
├── utils/               # Utility functions
├── application.py       # Flask application
├── main.py             # Main entry point
├── pyproject.toml      # Project metadata
└── README.md           # Project documentation
```

## Environment Setup

1. Create and activate virtual environment:
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows: .\venv\Scripts\activate
   ```

2. Install uv:
   ```bash
   python -m pip install uv
   ```

3. Initialize project with uv:
   ```bash
   uv init
   ```

4. Configure pyproject.toml:
   ```toml
   [project]
   name = "mlops_project_one"
   version = "0.1.0"
   description = "Hotel Booking Prediction MLOps Pipeline"
   requires-python = ">=3.11"
   dependencies = [
       "pandas",
       "scikit-learn",
       "lightgbm",
       "flask",
       "mlflow",
       "google-cloud-storage",
       "google-cloud-bigquery",
       "python-dotenv"
   ]

   [build-system]
   requires = ["hatchling"]
   build-backend = "hatchling.build"

   [tool.pytest.ini_options]
   testpaths = ["tests"]
   python_files = ["test_*.py"]
   ```

5. Install dependencies:
   ```bash
   uv install
   ```

## Configuration Files

### config.yaml
```yaml
data_ingestion:
  bucket_name: "hotel-booking-mlops-data"
  bucket_file_name: "raw/hotel_bookings.csv"
  train_ratio: 0.8

data_preprocessing:
  numerical_features:
    - "lead_time"
    - "avg_price_per_room"
  categorical_features:
    - "type_of_meal_plan"
    - "room_type_reserved"
  target_column: "booking_status"

model_training:
  model_type: "lightgbm"
  random_state: 42
  test_size: 0.2
```

### Environment Variables (.env)
```
LOG_DIR=logs
GCP_PROJECT=your-gcp-project-id
GOOGLE_APPLICATION_CREDENTIALS=path/to/service-account-key.json
```

## Development Tools

### VS Code Extensions
1. Python
2. Jupyter
3. Docker
4. YAML
5. Git History
6. MLflow

### Git Configuration
1. Setup .gitignore:
   ```
   venv/
   *.pyc
   __pycache__/
   .env
   logs/
   artifacts/
   mlruns/
   *.egg-info/
   ```

2. Configure git hooks for code quality:
   - Pre-commit hooks for linting
   - Pre-push hooks for tests

### Code Quality Tools
1. Install development tools:
   ```bash
   uv install -d black flake8 isort mypy pytest pytest-cov
   ```

2. Configure pre-commit:
   ```yaml
   # .pre-commit-config.yaml
   repos:
   - repo: https://github.com/psf/black
     rev: 22.3.0
     hooks:
     - id: black
   - repo: https://github.com/pycqa/flake8
     rev: 4.0.1
     hooks:
     - id: flake8
   ```

## Testing Setup

1. Create test structure:
   ```
   tests/
   ├── __init__.py
   ├── conftest.py
   ├── test_data_ingestion.py
   ├── test_data_preprocessing.py
   └── test_model_training.py
   ```

2. Configure pytest.ini:
   ```ini
   [pytest]
   testpaths = tests
   python_files = test_*.py
   python_functions = test_*
   ```

## Logging Configuration

1. Setup logger (src/logger.py):
   ```python
   import logging
   import os
   from datetime import datetime

   LOG_DIR = os.getenv("LOG_DIR", "logs")
   os.makedirs(LOG_DIR, exist_ok=True)

   log_filename = f"log_{datetime.now().strftime('%Y-%m-%d')}.log"
   logging.basicConfig(
       filename=os.path.join(LOG_DIR, log_filename),
       level=logging.INFO,
       format="%(asctime)s — %(name)s — %(levelname)s — %(message)s"
   )
   ```

## Error Handling

1. Custom exceptions (src/custom_exception.py):
   ```python
   class CustomException(Exception):
       def __init__(self, message, error):
           super().__init__(message)
           self.error = error
   ```

## Verification Steps

1. Test environment setup:
   ```bash
   python -c "import pandas, sklearn, lightgbm, flask, mlflow"
   ```

2. Run logger test:
   ```bash
   python src/test_setup.py
   ```

3. Verify project structure:
   ```bash
   tree -I 'venv|*.pyc|__pycache__|*.egg-info'
   ```

## Troubleshooting

Common setup issues and solutions:
1. Python version conflicts:
   - Use pyenv to manage Python versions
   - Verify Python path in virtual environment
2. Dependency conflicts:
   - Clear pip cache
   - Update uv.lock file
3. Permission issues:
   - Check file/directory permissions
   - Verify user access rights