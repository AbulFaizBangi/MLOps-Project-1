# MLflow Experiment Tracking

## Overview
This document details the experiment tracking setup using MLflow for the Hotel Booking Prediction system, enabling reproducible machine learning experiments and model versioning.

## Table of Contents
1. [MLflow Setup](#mlflow-setup)
2. [Experiment Configuration](#experiment-configuration)
3. [Tracking Components](#tracking-components)
4. [Model Registry](#model-registry)
5. [Visualization](#visualization)

## MLflow Setup

### Installation and Configuration
```bash
# Install MLflow
pip install mlflow

# Start MLflow server
mlflow server \
    --backend-store-uri sqlite:///mlflow.db \
    --default-artifact-root ./artifacts/mlflow-artifacts \
    --host 0.0.0.0 \
    --port 5000
```

### Directory Structure
```
mlruns/
├── 0/                      # Default experiment
│   ├── meta.yaml          # Experiment metadata
│   └── runs/              # Individual experiment runs
│       ├── run_id_1/      # Run specific data
│       │   ├── artifacts/ # Model files and plots
│       │   ├── metrics/   # Performance metrics
│       │   ├── params/    # Model parameters
│       │   └── tags/      # Run metadata
│       └── run_id_2/
└── models/                # Registered models
```

## Experiment Configuration

### MLflow Tracking
```python
class ExperimentTracker:
    def __init__(self, experiment_name="hotel_booking_prediction"):
        self.experiment_name = experiment_name
        mlflow.set_tracking_uri("http://localhost:5000")
        
    def setup_experiment(self):
        """Setup or get existing experiment"""
        try:
            experiment = mlflow.get_experiment_by_name(self.experiment_name)
            if experiment is None:
                experiment_id = mlflow.create_experiment(self.experiment_name)
            else:
                experiment_id = experiment.experiment_id
                
            mlflow.set_experiment(experiment_id)
            return experiment_id
            
        except Exception as e:
            logger.error("Error setting up MLflow experiment")
            raise CustomException("Failed to setup experiment", e)
```

## Tracking Components

### Parameter Tracking
```python
def log_parameters(params):
    """Log model parameters"""
    mlflow.log_params({
        "model_type": "lightgbm",
        "objective": params["objective"],
        "metric": params["metric"],
        "num_leaves": params["num_leaves"],
        "learning_rate": params["learning_rate"],
        "feature_fraction": params["feature_fraction"]
    })
```

### Metric Tracking
```python
def log_metrics(metrics):
    """Log model performance metrics"""
    mlflow.log_metrics({
        "accuracy": metrics["accuracy"],
        "precision": metrics["precision"],
        "recall": metrics["recall"],
        "f1_score": metrics["f1"],
        "auc_roc": metrics["auc_roc"]
    })
```

### Artifact Logging
```python
def log_artifacts(model, feature_importance_plot):
    """Log model artifacts"""
    # Log the model
    mlflow.lightgbm.log_model(model, "model")
    
    # Log feature importance plot
    mlflow.log_artifact(feature_importance_plot, "feature_importance.png")
    
    # Log confusion matrix
    mlflow.log_artifact(confusion_matrix_plot, "confusion_matrix.png")
```

## Model Registry

### Model Registration
```python
def register_model(run_id, model_name="hotel_booking_model"):
    """Register model in MLflow registry"""
    try:
        result = mlflow.register_model(
            f"runs:/{run_id}/model",
            model_name
        )
        return result.version
        
    except Exception as e:
        logger.error("Error registering model")
        raise CustomException("Failed to register model", e)
```

### Model Versioning
```python
def transition_model_stage(model_name, version, stage):
    """Transition model to different stages"""
    client = mlflow.tracking.MlflowClient()
    client.transition_model_version_stage(
        name=model_name,
        version=version,
        stage=stage
    )
```

## Visualization

### MLflow UI Access
- URL: http://localhost:5000
- Features:
  - Experiment comparison
  - Run history
  - Parameter tracking
  - Metric visualization
  - Artifact browsing

### Metric Visualization
```python
def plot_metrics(metrics_dict):
    """Create metric visualization plots"""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    # Plot metrics
    ax.bar(metrics_dict.keys(), metrics_dict.values())
    ax.set_title("Model Performance Metrics")
    ax.set_ylabel("Score")
    
    # Save plot
    plt.savefig("metric_comparison.png")
    mlflow.log_artifact("metric_comparison.png")
```

## Integration Examples

### Training Pipeline Integration
```python
def train_with_tracking():
    """Train model with MLflow tracking"""
    with mlflow.start_run() as run:
        # Log parameters
        log_parameters(model_params)
        
        # Train model
        model = train_model()
        
        # Log metrics
        metrics = evaluate_model(model)
        log_metrics(metrics)
        
        # Log model and artifacts
        log_artifacts(model)
        
        # Register model
        version = register_model(run.info.run_id)
        
        return model, metrics, version
```

### Experiment Comparison
```python
def compare_experiments(experiment_id, metric="f1_score"):
    """Compare different experiment runs"""
    client = mlflow.tracking.MlflowClient()
    runs = client.search_runs(
        experiment_id,
        order_by=[f"metrics.{metric} DESC"]
    )
    
    return [(run.info.run_id, run.data.metrics[metric]) 
            for run in runs]
```

## Best Practices

1. Parameter Tracking
   - Log all hyperparameters
   - Include data preprocessing parameters
   - Track environment information

2. Metric Logging
   - Log all relevant metrics
   - Include training and validation metrics
   - Track timing information

3. Artifact Management
   - Save model checkpoints
   - Store visualization plots
   - Keep feature importance data

4. Model Registry
   - Use semantic versioning
   - Implement stage transitions
   - Document model versions

## Troubleshooting

1. Connection Issues
   - Check MLflow server status
   - Verify tracking URI
   - Validate network connectivity

2. Logging Errors
   - Check parameter types
   - Verify metric values
   - Ensure artifact paths

3. Registry Problems
   - Check model format
   - Verify version numbers
   - Validate stage transitions