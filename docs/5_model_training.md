# Model Training

## Overview
This document details the model training process for the Hotel Booking Prediction system, including model selection, hyperparameter tuning, and evaluation.

## Table of Contents
1. [Model Selection](#model-selection)
2. [Training Pipeline](#training-pipeline)
3. [Hyperparameter Tuning](#hyperparameter-tuning)
4. [Model Evaluation](#model-evaluation)
5. [Model Persistence](#model-persistence)
6. [MLflow Integration](#mlflow-integration)

## Model Selection

### LightGBM Model
We chose LightGBM for its:
- Fast training and inference speed
- Handling of categorical features
- Memory efficiency
- Good performance on tabular data

### Model Architecture
```python
model_params = {
    'objective': 'binary',
    'metric': 'binary_logloss',
    'boosting_type': 'gbdt',
    'num_leaves': 31,
    'learning_rate': 0.05,
    'feature_fraction': 0.9
}
```

## Training Pipeline

### ModelTraining Class
```python
class ModelTraining:
    def __init__(self, train_path, test_path, model_path):
        self.train_path = train_path
        self.test_path = test_path
        self.model_path = model_path
        
    def load_data(self):
        """Load processed training and testing data"""
        self.X_train = pd.read_csv(self.train_path)
        self.y_train = self.X_train.pop('booking_status')
        
        self.X_test = pd.read_csv(self.test_path)
        self.y_test = self.X_test.pop('booking_status')
        
    def train_model(self):
        """Train LightGBM model with tracking"""
        try:
            with mlflow.start_run():
                # Log parameters
                mlflow.log_params(model_params)
                
                # Create and train model
                model = lgb.LGBMClassifier(**model_params)
                model.fit(
                    self.X_train, self.y_train,
                    eval_set=[(self.X_test, self.y_test)],
                    eval_metric='binary_logloss',
                    early_stopping_rounds=10,
                    verbose=100
                )
                
                # Log metrics
                y_pred = model.predict(self.X_test)
                metrics = {
                    'accuracy': accuracy_score(self.y_test, y_pred),
                    'precision': precision_score(self.y_test, y_pred),
                    'recall': recall_score(self.y_test, y_pred),
                    'f1': f1_score(self.y_test, y_pred)
                }
                mlflow.log_metrics(metrics)
                
                # Save model
                mlflow.lightgbm.log_model(model, "model")
                joblib.dump(model, self.model_path)
                
                return model, metrics
                
        except Exception as e:
            logger.error("Error in model training")
            raise CustomException("Failed to train model", e)
```

## Hyperparameter Tuning

### Parameter Grid
```python
param_grid = {
    'num_leaves': [15, 31, 63],
    'learning_rate': [0.01, 0.05, 0.1],
    'n_estimators': [100, 200, 300],
    'min_child_samples': [20, 30, 50],
    'subsample': [0.8, 0.9, 1.0],
    'colsample_bytree': [0.8, 0.9, 1.0]
}
```

### Tuning Process
```python
def tune_hyperparameters(self):
    """Perform hyperparameter tuning"""
    try:
        with mlflow.start_run(nested=True):
            # Random search with cross-validation
            model = lgb.LGBMClassifier()
            random_search = RandomizedSearchCV(
                estimator=model,
                param_distributions=param_grid,
                n_iter=20,
                cv=5,
                random_state=42,
                scoring='f1'
            )
            
            random_search.fit(self.X_train, self.y_train)
            
            # Log best parameters
            mlflow.log_params(random_search.best_params_)
            
            return random_search.best_estimator_
            
    except Exception as e:
        logger.error("Error in hyperparameter tuning")
        raise CustomException("Failed to tune hyperparameters", e)
```

## Model Evaluation

### Evaluation Metrics
```python
def evaluate_model(self, model):
    """Evaluate model performance"""
    try:
        # Make predictions
        y_pred = model.predict(self.X_test)
        y_prob = model.predict_proba(self.X_test)[:, 1]
        
        # Calculate metrics
        metrics = {
            'accuracy': accuracy_score(self.y_test, y_pred),
            'precision': precision_score(self.y_test, y_pred),
            'recall': recall_score(self.y_test, y_pred),
            'f1': f1_score(self.y_test, y_pred),
            'auc_roc': roc_auc_score(self.y_test, y_prob)
        }
        
        # Generate confusion matrix
        cm = confusion_matrix(self.y_test, y_pred)
        
        # Feature importance
        feature_imp = pd.DataFrame({
            'feature': self.X_train.columns,
            'importance': model.feature_importances_
        }).sort_values('importance', ascending=False)
        
        return metrics, cm, feature_imp
        
    except Exception as e:
        logger.error("Error in model evaluation")
        raise CustomException("Failed to evaluate model", e)
```

## Model Persistence

### Save Model
```python
def save_model(self, model):
    """Save trained model"""
    try:
        # Save with joblib
        joblib.dump(model, self.model_path)
        
        # Log with MLflow
        mlflow.lightgbm.log_model(model, "model")
        
        logger.info(f"Model saved to {self.model_path}")
        
    except Exception as e:
        logger.error("Error saving model")
        raise CustomException("Failed to save model", e)
```

### Load Model
```python
def load_model(model_path):
    """Load trained model"""
    try:
        model = joblib.load(model_path)
        return model
    except Exception as e:
        logger.error("Error loading model")
        raise CustomException("Failed to load model", e)
```

## MLflow Integration

### Experiment Tracking
```python
def track_experiment(self, run_name, model, params, metrics):
    """Track experiment with MLflow"""
    try:
        with mlflow.start_run(run_name=run_name):
            # Log parameters
            mlflow.log_params(params)
            
            # Log metrics
            mlflow.log_metrics(metrics)
            
            # Log model
            mlflow.lightgbm.log_model(model, "model")
            
            # Log feature importance plot
            fig, ax = plt.subplots(figsize=(10, 6))
            plot_importance(model, ax=ax)
            mlflow.log_figure(fig, "feature_importance.png")
            
    except Exception as e:
        logger.error("Error tracking experiment")
        raise CustomException("Failed to track experiment", e)
```

## Testing

### Model Tests
```python
def test_model_training():
    """Test model training pipeline"""
    trainer = ModelTraining(PROCESSED_TRAIN_PATH, PROCESSED_TEST_PATH, MODEL_PATH)
    
    # Test data loading
    trainer.load_data()
    assert trainer.X_train is not None
    assert trainer.y_train is not None
    
    # Test model training
    model, metrics = trainer.train_model()
    assert isinstance(model, lgb.LGBMClassifier)
    assert metrics['accuracy'] > 0.7
    
    # Test model saving
    assert os.path.exists(MODEL_PATH)
```

## Monitoring

### Training Metrics
```python
def log_training_metrics(metrics, run_id):
    """Log training metrics"""
    logger.info(f"Training metrics for run {run_id}:")
    for metric, value in metrics.items():
        logger.info(f"{metric}: {value:.4f}")
```

### Model Performance Monitoring
```python
def monitor_model_performance(y_true, y_pred, threshold=0.7):
    """Monitor model performance"""
    accuracy = accuracy_score(y_true, y_pred)
    if accuracy < threshold:
        logger.warning(f"Model performance below threshold: {accuracy:.4f}")
        # Trigger retraining notification
```

## Troubleshooting Guide

1. Training Issues
   - Check input data quality
   - Verify feature engineering steps
   - Monitor memory usage
   - Check for class imbalance

2. Performance Issues
   - Review feature importance
   - Check for overfitting
   - Validate hyperparameters
   - Verify evaluation metrics

3. MLflow Issues
   - Check tracking server
   - Verify artifact storage
   - Monitor experiment logging