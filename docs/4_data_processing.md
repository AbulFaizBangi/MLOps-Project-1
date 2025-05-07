# Data Processing

## Overview
This document outlines the data preprocessing pipeline for the Hotel Booking Prediction system, including feature engineering, cleaning, and transformation steps.

## Table of Contents
1. [Feature Engineering](#feature-engineering)
2. [Data Cleaning](#data-cleaning)
3. [Feature Transformation](#feature-transformation)
4. [Implementation](#implementation)
5. [Configuration](#configuration)
6. [Quality Control](#quality-control)

## Feature Engineering

### Derived Features
1. Total Nights:
   ```python
   df['total_nights'] = df['no_of_weekend_nights'] + df['no_of_week_nights']
   ```

2. Total Guests:
   ```python
   df['total_guests'] = df['no_of_adults'] + df['no_of_children']
   ```

3. Price Per Person:
   ```python
   df['price_per_person'] = df['avg_price_per_room'] / df['total_guests']
   ```

4. Booking Lead Time Categories:
   ```python
   def categorize_lead_time(days):
       if days <= 7: return 'last_minute'
       elif days <= 30: return 'short_term'
       elif days <= 90: return 'medium_term'
       else: return 'long_term'
   
   df['lead_time_category'] = df['lead_time'].apply(categorize_lead_time)
   ```

### Temporal Features
1. Season from arrival date:
   ```python
   def get_season(month):
       if month in [12, 1, 2]: return 'winter'
       elif month in [3, 4, 5]: return 'spring'
       elif month in [6, 7, 8]: return 'summer'
       else: return 'fall'
   
   df['arrival_season'] = df['arrival_month'].apply(get_season)
   ```

## Data Cleaning

### Missing Value Strategy
```python
class DataCleaner:
    def handle_missing_values(self, df):
        # Numerical columns
        numerical_imputer = SimpleImputer(strategy='median')
        df[numerical_cols] = numerical_imputer.fit_transform(df[numerical_cols])
        
        # Categorical columns
        categorical_imputer = SimpleImputer(strategy='most_frequent')
        df[categorical_cols] = categorical_imputer.fit_transform(df[categorical_cols])
        
        return df
```

### Outlier Detection and Treatment
```python
def handle_outliers(df, columns, method='iqr'):
    for column in columns:
        Q1 = df[column].quantile(0.25)
        Q3 = df[column].quantile(0.75)
        IQR = Q3 - Q1
        lower_bound = Q1 - 1.5 * IQR
        upper_bound = Q3 + 1.5 * IQR
        
        # Cap outliers
        df[column] = df[column].clip(lower_bound, upper_bound)
    
    return df
```

## Feature Transformation

### Numerical Features
```python
class FeatureTransformer:
    def transform_numerical(self, df):
        # Log transform for skewed features
        skewed_features = ['lead_time', 'avg_price_per_room']
        for feature in skewed_features:
            df[f'{feature}_log'] = np.log1p(df[feature])
            
        # Standard scaling
        scaler = StandardScaler()
        scaled_features = scaler.fit_transform(df[numerical_cols])
        df[numerical_cols] = scaled_features
        
        return df
```

### Categorical Features
```python
    def transform_categorical(self, df):
        # Ordinal encoding for ordered categories
        ordinal_features = {
            'type_of_meal_plan': ['Not Selected', 'Meal Plan 1', 'Meal Plan 2', 'Meal Plan 3'],
            'room_type_reserved': ['Room_Type 1', 'Room_Type 2', 'Room_Type 3', 'Room_Type 4', 
                                 'Room_Type 5', 'Room_Type 6', 'Room_Type 7']
        }
        
        for feature, categories in ordinal_features.items():
            encoder = OrdinalEncoder(categories=[categories])
            df[feature] = encoder.fit_transform(df[[feature]])
        
        # One-hot encoding for nominal categories
        nominal_features = ['market_segment_type', 'arrival_season']
        df = pd.get_dummies(df, columns=nominal_features, prefix=nominal_features)
        
        return df
```

## Implementation

### DataProcessor Class
```python
class DataProcessor:
    def __init__(self, train_path, test_path, processed_dir, config_path):
        self.train_path = train_path
        self.test_path = test_path
        self.processed_dir = processed_dir
        self.config = read_yaml(config_path)
        
        os.makedirs(processed_dir, exist_ok=True)
        
    def load_data(self):
        """Load train and test datasets"""
        self.train_df = pd.read_csv(self.train_path)
        self.test_df = pd.read_csv(self.test_path)
        
    def process(self):
        """Execute complete preprocessing pipeline"""
        try:
            logger.info("Starting data preprocessing")
            self.load_data()
            
            # Feature engineering
            self.train_df = self.engineer_features(self.train_df)
            self.test_df = self.engineer_features(self.test_df)
            
            # Clean data
            cleaner = DataCleaner()
            self.train_df = cleaner.handle_missing_values(self.train_df)
            self.test_df = cleaner.handle_missing_values(self.test_df)
            
            # Transform features
            transformer = FeatureTransformer()
            self.train_df = transformer.transform_all(self.train_df)
            self.test_df = transformer.transform_all(self.test_df)
            
            # Save processed data
            self.save_processed_data()
            logger.info("Data preprocessing completed successfully")
            
        except Exception as e:
            logger.error("Error in data preprocessing")
            raise CustomException("Failed to process data", e)
```

## Configuration

### config.yaml
```yaml
data_preprocessing:
  numerical_features:
    - lead_time
    - avg_price_per_room
    - no_of_special_requests
    - total_nights
    - price_per_person
    
  categorical_features:
    - type_of_meal_plan
    - room_type_reserved
    - market_segment_type
    - arrival_season
    
  target_column: booking_status
  
  outlier_treatment:
    method: iqr
    columns:
      - lead_time
      - avg_price_per_room
```

## Quality Control

### Data Quality Checks
```python
def validate_processed_data(df):
    """Validate processed dataset"""
    try:
        # Check for missing values
        assert df.isnull().sum().sum() == 0, "Found missing values"
        
        # Check feature ranges
        assert df['lead_time'].between(0, 1).all(), "Lead time not scaled properly"
        
        # Check categorical encodings
        for col in categorical_cols:
            assert df[col].dtype in ['int64', 'float64'], f"Categorical column {col} not encoded"
            
        return True
        
    except AssertionError as e:
        logger.error(f"Validation failed: {str(e)}")
        return False
```

### Processing Metrics
1. Feature distributions before/after transformation
2. Missing value counts
3. Outlier detection counts
4. Encoding validation
5. Memory usage optimization

## Monitoring

### Logging
```python
logger.info("Shape before processing: %s", df.shape)
logger.info("Missing values: %s", df.isnull().sum().sum())
logger.info("Memory usage: %s MB", df.memory_usage().sum() / 1024**2)
logger.info("Shape after processing: %s", df.shape)
```

### Data Drift Detection
```python
def check_data_drift(reference_data, current_data, threshold=0.1):
    """Check for data drift between reference and current data"""
    for column in numerical_cols:
        ks_statistic, p_value = ks_2samp(
            reference_data[column],
            current_data[column]
        )
        if p_value < threshold:
            logger.warning(f"Data drift detected in {column}")
```

## Testing

### Unit Tests
```python
def test_data_processor():
    """Test data preprocessing pipeline"""
    processor = DataProcessor(TRAIN_PATH, TEST_PATH, PROCESSED_DIR, CONFIG_PATH)
    
    # Test feature engineering
    df = processor.engineer_features(sample_df)
    assert 'total_nights' in df.columns
    
    # Test transformations
    df = processor.transform_features(df)
    assert df.isnull().sum().sum() == 0
    
    # Test data quality
    assert validate_processed_data(df)
```

## Troubleshooting Guide

1. Missing Features
   - Check feature engineering steps
   - Verify column names in config
   - Validate input data schema

2. Transformation Errors
   - Check data types
   - Verify category levels
   - Debug scaling issues

3. Memory Issues
   - Optimize data types
   - Use chunked processing
   - Monitor memory usage