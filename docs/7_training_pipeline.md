# Training Pipeline

## Overview
This document details the end-to-end training pipeline that orchestrates data ingestion, preprocessing, model training, and experiment tracking for the Hotel Booking Prediction system.

## Table of Contents
1. [Pipeline Architecture](#pipeline-architecture)
2. [Implementation](#implementation)
3. [Pipeline Components](#pipeline-components)
4. [Configuration](#configuration)
5. [Error Handling](#error-handling)
6. [Monitoring](#monitoring)

## Pipeline Architecture

### Pipeline Flow
```
Data Ingestion → Data Processing → Model Training → MLflow Tracking
     ↓               ↓                ↓                ↓
   Raw Data → Processed Data → Trained Model → Tracked Experiments
```

### Component Interaction
- Data Ingestion loads and splits data
- Data Processing handles feature engineering
- Model Training manages model creation
- MLflow tracks experiments and artifacts

## Implementation

### TrainingPipeline Class
```python
class TrainingPipeline:
    def __init__(self, config_path: str = "config/config.yaml"):
        self.config = read_yaml(config_path)
        self.experiment_tracker = ExperimentTracker()
        
    def run(self):
        """Execute complete training pipeline"""
        try:
            logger.info("Starting training pipeline")
            
            # Initialize MLflow experiment
            experiment_id = self.experiment_tracker.setup_experiment()
            
            with mlflow.start_run(experiment_id=experiment_id) as run:
                # Data Ingestion
                ingestion = DataIngestion(self.config)
                train_path, test_path = ingestion.run()
                
                # Data Processing
                processor = DataProcessor(train_path, test_path)
                processed_train, processed_test = processor.process()
                
                # Model Training
                trainer = ModelTraining(processed_train, processed_test)
                model, metrics = trainer.train_model()
                
                # Log experiment
                self.log_experiment(model, metrics)
                
                # Save artifacts
                self.save_artifacts(model, metrics)
                
                logger.info("Training pipeline completed successfully")
                return model, metrics
                
        except Exception as e:
            logger.error("Error in training pipeline")
            raise CustomException("Pipeline execution failed", e)
```

## Pipeline Components

### Component Configuration
```python
def setup_components(self):
    """Initialize pipeline components"""
    try:
        # Setup data ingestion
        self.ingestion = DataIngestion(
            config=self.config["data_ingestion"]
        )
        
        # Setup data processing
        self.processor = DataProcessor(
            config=self.config["data_preprocessing"]
        )
        
        # Setup model training
        self.trainer = ModelTraining(
            config=self.config["model_training"]
        )
        
        # Setup experiment tracking
        self.tracker = ExperimentTracker(
            experiment_name=self.config["mlflow"]["experiment_name"]
        )
        
    except Exception as e:
        logger.error("Error setting up pipeline components")
        raise CustomException("Component setup failed", e)
```

### Pipeline Execution
```python
def execute_pipeline(self):
    """Run pipeline steps in sequence"""
    try:
        # Step 1: Data Ingestion
        logger.info("Starting data ingestion")
        train_data, test_data = self.ingestion.run()
        
        # Step 2: Data Processing
        logger.info("Starting data processing")
        processed_train = self.processor.process(train_data)
        processed_test = self.processor.process(test_data)
        
        # Step 3: Model Training
        logger.info("Starting model training")
        model = self.trainer.train_model(processed_train)
        
        # Step 4: Model Evaluation
        logger.info("Evaluating model")
        metrics = self.trainer.evaluate_model(model, processed_test)
        
        return model, metrics
        
    except Exception as e:
        logger.error(f"Pipeline execution failed: {str(e)}")
        raise
```

## Configuration

### config.yaml
```yaml
pipeline:
  name: "hotel_booking_prediction"
  version: "1.0.0"
  
  components:
    data_ingestion:
      enabled: true
      validate_data: true
      
    data_processing:
      enabled: true
      handle_missing: true
      handle_outliers: true
      
    model_training:
      enabled: true
      cross_validation: true
      hyperparameter_tuning: true
      
    experiment_tracking:
      enabled: true
      log_artifacts: true
```

### Pipeline Settings
```python
def load_pipeline_config(self):
    """Load pipeline configuration"""
    try:
        pipeline_config = self.config["pipeline"]
        
        # Validate configuration
        required_keys = ["name", "version", "components"]
        if not all(key in pipeline_config for key in required_keys):
            raise ValueError("Missing required configuration keys")
            
        return pipeline_config
        
    except Exception as e:
        logger.error("Error loading pipeline configuration")
        raise CustomException("Configuration loading failed", e)
```

## Error Handling

### Pipeline Recovery
```python
def handle_component_failure(self, component_name, error):
    """Handle component failures"""
    try:
        logger.error(f"Component failure in {component_name}: {str(error)}")
        
        # Cleanup any temporary artifacts
        self.cleanup_artifacts()
        
        # Log failure in MLflow
        if mlflow.active_run():
            mlflow.log_param("failure_component", component_name)
            mlflow.log_param("error_message", str(error))
            
        # Notify administrators
        self.send_failure_notification(component_name, error)
        
    except Exception as e:
        logger.error(f"Error handling component failure: {str(e)}")
```

### Data Validation
```python
def validate_pipeline_data(self, data, stage):
    """Validate data at each pipeline stage"""
    try:
        if data is None:
            raise ValueError(f"No data received at {stage}")
            
        # Check data format
        if not isinstance(data, pd.DataFrame):
            raise TypeError(f"Invalid data type at {stage}")
            
        # Check required columns
        required_columns = self.config[stage]["required_columns"]
        missing_columns = set(required_columns) - set(data.columns)
        if missing_columns:
            raise ValueError(f"Missing columns at {stage}: {missing_columns}")
            
        return True
        
    except Exception as e:
        logger.error(f"Data validation failed at {stage}")
        raise CustomException("Data validation failed", e)
```

## Monitoring

### Pipeline Metrics
```python
def track_pipeline_metrics(self):
    """Track pipeline performance metrics"""
    metrics = {
        "pipeline_start_time": self.start_time,
        "pipeline_end_time": self.end_time,
        "total_duration": self.end_time - self.start_time,
        "data_ingestion_duration": self.ingestion_duration,
        "processing_duration": self.processing_duration,
        "training_duration": self.training_duration
    }
    
    # Log metrics to MLflow
    mlflow.log_metrics(metrics)
```

### Resource Monitoring
```python
def monitor_resources(self):
    """Monitor system resources during pipeline execution"""
    try:
        # Memory usage
        memory_usage = psutil.Process().memory_info().rss / 1024 / 1024
        logger.info(f"Memory usage: {memory_usage:.2f} MB")
        
        # CPU usage
        cpu_percent = psutil.cpu_percent(interval=1)
        logger.info(f"CPU usage: {cpu_percent}%")
        
        # Disk usage
        disk_usage = psutil.disk_usage('/').percent
        logger.info(f"Disk usage: {disk_usage}%")
        
    except Exception as e:
        logger.warning(f"Resource monitoring failed: {str(e)}")
```

## Testing

### Pipeline Tests
```python
def test_training_pipeline():
    """Test complete training pipeline"""
    pipeline = TrainingPipeline()
    
    # Test pipeline initialization
    assert pipeline.config is not None
    
    # Test component setup
    pipeline.setup_components()
    assert pipeline.ingestion is not None
    assert pipeline.processor is not None
    assert pipeline.trainer is not None
    
    # Test pipeline execution
    model, metrics = pipeline.run()
    assert model is not None
    assert metrics["accuracy"] > 0.7
```

## Troubleshooting Guide

1. Pipeline Failures
   - Check component logs
   - Verify data consistency
   - Monitor system resources
   - Review configuration

2. Performance Issues
   - Check data volumes
   - Monitor processing times
   - Review resource usage
   - Optimize bottlenecks

3. Integration Problems
   - Verify component interfaces
   - Check data formats
   - Validate configurations
   - Test connections