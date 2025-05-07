# Hotel Reservation Prediction MLOps Project

Welcome to the **Hotel Reservation Prediction** MLOps project. This project implements an end-to-end machine learning pipeline for predicting hotel reservation status, with a Flask-based web interface and robust MLOps practices.

---

## 📁 Project Structure

```text
Project-1/
├── pyproject.toml          # Project configuration and dependencies
├── uv.lock                 # Dependency lock file
├── application.py         # Flask application entry point
├── main.py               # Main execution script
├── src/
│   ├── logger.py           # Logging configuration
│   ├── custom_exception.py # Custom error handling
│   ├── data_ingestion.py  # Data loading and splitting
│   ├── data_preprocessing.py # Feature processing
│   └── model_training.py   # Model training logic
├── config/
│   ├── config.yaml        # Configuration parameters
│   ├── model_params.py    # Model hyperparameters
│   └── paths_config.py    # File path configurations
├── utils/
│   └── common_functions.py # Shared utility functions
├── pipeline/
│   └── training_pipeline.py # End-to-end training workflow
├── artifacts/
│   ├── models/            # Trained model files
│   ├── processed/         # Processed datasets
│   └── raw/              # Raw input data
├── mlruns/                # MLflow tracking
├── templates/             # Flask HTML templates
├── static/               # CSS and static assets
└── logs/                 # Application logs
```

## 🔄 Project Workflow

Our MLOps pipeline consists of several key stages:

1. **Database Setup**: Initial data storage configuration
2. **Project Setup**: Repository and environment configuration
3. **Data Ingestion**: Loading and splitting of hotel reservation data
4. **Data Processing**: Feature engineering and preprocessing
5. **Model Training**: Training and validation of prediction models
6. **Experiment Tracking**: Using MLflow for experiment management
7. **Training Pipeline**: Automated end-to-end training workflow
8. **User App Building**: Flask-based web interface
9. **CI-CD Deployment**: Jenkins and Docker deployment setup

## 🚀 Getting Started

---

## Prerequisites

- Python 3.8+ installed
- VS Code or another code editor
- Basic familiarity with Python

---

## 1. Initialize with uv

```bash
# Create project directory and enter it
mkdir MLOps_Project_One && cd MLOps_Project_One

# Initialize uv (creates pyproject.toml & default settings)
uv init
```

This generates a `pyproject.toml` with your project name, version, and default settings.

---

## 2. Add Dependencies

Instead of editing `requirements.txt`, use:

```bash
uv add pandas numpy scikit-learn flask python-dotenv
```

This updates both `pyproject.toml` and the lockfile (`uv.lock`) automatically.

---

## 3. Create & Activate the Environment

```bash
# Install dependencies and create a virtual environment under .venv
uv install

# Activate the uv-managed environment
uv shell
```

Your packages are now isolated within `.venv/`.

---

## 4. Project Metadata & Packaging

All packaging info lives in **pyproject.toml**. You **do not** need `setup.py`:

```toml
[project]
name = "mlops_project_one"
version = "0.1.0"
description = "An MLOps project scaffolded with uv"
authors = [
  { name = "Your Name", email = "you@example.com" }
]

[tool.uv]
# uv-specific configuration goes here
```

---

## 5. Logger Setup (`src/logger.py`)

```python
import logging
import os
from datetime import datetime

LOG_DIR = os.getenv("LOG_DIR", "logs")
os.makedirs(LOG_DIR, exist_ok=True)

log_filename = datetime.now().strftime("app_%Y%m%d_%H%M%S.log")
logging.basicConfig(
    filename=os.path.join(LOG_DIR, log_filename),
    level=logging.INFO,
    format="%(asctime)s — %(name)s — %(levelname)s — %(message)s"
)
logger = logging.getLogger(__name__)
```

---

## 6. Custom Exceptions (`src/custom_exception.py`)

```python
class MLOpsError(Exception):
    """Base class for MLOps exceptions."""
    pass

class DataValidationError(MLOpsError):
    """Raised when input data fails validation."""
    def __init__(self, message, errors=None):
        super().__init__(message)
        self.errors = errors
```

---

## 7. Testing Your Setup

1. Create `src/test_setup.py`:

   ```python
   from src.logger import logger
   from src.custom_exception import DataValidationError

   def main():
       logger.info("Testing logger")
       try:
           raise DataValidationError("Invalid data format", errors={"field": "age"})
       except DataValidationError as e:
           logger.error(f"Caught an error: {e}, details: {e.errors}")

   if __name__ == "__main__":
       main()
   ```

2. Run within the uv environment:

   ```bash
   uv shell
   python src/test_setup.py
   ```

3. Confirm a new log file appears under `logs/` with INFO and ERROR entries.

---

## 📊 MLflow Integration

MLflow is used for experiment tracking and model management. All experiments are stored in the `mlruns/` directory:

```bash
# Start MLflow UI
mlflow ui
```

Visit `http://localhost:5000` to view:
- Model performance metrics
- Parameter configurations
- Artifacts and model files
- Experiment comparisons

## 🌐 Web Interface

The project includes a Flask web interface for real-time predictions:

1. **Templates**: `templates/index.html` contains the prediction form
2. **Styling**: `static/style.css` provides a clean, responsive design
3. **Features**:
   - Lead time input
   - Special requests
   - Room type selection
   - Meal plan options
   - Real-time prediction results

## 📚 Project Documentation

- [Setup Guide](setup.md) - Detailed setup and installation instructions
- [Project Blog](blog.md) - Project development journey and technical insights
- [Jupyter Notebook Documentation](notebook/notebook.md) - Data analysis and model development documentation

## 📚 Detailed Documentation

1. [Database Setup](docs/1_database_setup.md) - Initial data storage configuration
2. [Project Setup](docs/2_project_setup.md) - Repository and environment configuration
3. [Data Ingestion](docs/3_data_ingestion.md) - Loading and splitting of hotel reservation data
4. [Data Processing](docs/4_data_processing.md) - Feature engineering and preprocessing
5. [Model Training](docs/5_model_training.md) - Training and validation of prediction models
6. [Experiment Tracking](docs/6_experiment_tracking.md) - Using MLflow for experiment management
7. [Training Pipeline](docs/7_training_pipeline.md) - Automated end-to-end training workflow
8. [User App](docs/8_user_app.md) - Flask-based web interface
9. [CI/CD Deployment](docs/9_cicd_deployment.md) - Jenkins and Docker deployment setup

## 🚢 Deployment

### Docker Setup
```dockerfile
# Build the image
docker build -t hotel-prediction .

# Run the container
docker run -p 5000:5000 hotel-prediction
```

### Jenkins Pipeline
The `Jenkinsfile` defines our CI/CD pipeline:
- Automated testing
- Docker image building
- Deployment stages
- Monitoring setup

## 📝 License

MIT License - feel free to use and modify as needed!

## Recap

- **uv init** to bootstrap your project  
- **uv add** to manage dependencies  
- **uv install & uv shell** to create & activate your environment  
- **pyproject.toml** replaces `setup.py` & `requirements.txt`  
- Organized directories for maintainable MLOps workflows  

Happy coding! 🚀

