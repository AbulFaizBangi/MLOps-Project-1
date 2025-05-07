# Data Ingestion

## Overview
This document details the data ingestion process for the Hotel Booking Prediction system, including data loading, validation, and splitting operations.

## Table of Contents
1. [Data Source](#data-source)
2. [Data Ingestion Pipeline](#data-ingestion-pipeline)
3. [Configuration](#configuration)
4. [Implementation](#implementation)
5. [Quality Checks](#quality-checks)
6. [Error Handling](#error-handling)

## Data Source

### Hotel Bookings Dataset
- Source: Google Cloud Storage
- Format: CSV
- Location: `hotel-booking-mlops-data/raw/hotel_bookings.csv`
- Size: ~50MB

### Data Schema
```python
schema = {
    "booking_id": "string",
    "no_of_adults": "int",
    "no_of_children": "int",
    "no_of_weekend_nights": "int",
    "no_of_week_nights": "int",
    "type_of_meal_plan": "string",
    "required_car_parking_space": "int",
    "room_type_reserved": "string",
    "lead_time": "int",
    "arrival_year": "int",
    "arrival_month": "int",
    "arrival_date": "int",
    "market_segment_type": "string",
    "repeated_guest": "int",
    "no_of_previous_cancellations": "int",
    "no_of_previous_bookings_not_canceled": "int",
    "avg_price_per_room": "float",
    "no_of_special_requests": "int",
    "booking_status": "int"
}
```

## Data Ingestion Pipeline

### Process Flow
1. Configuration Loading
2. GCP Authentication
3. Raw Data Download
4. Data Validation
5. Train-Test Split
6. Save Processed Data

### Directory Structure
```
artifacts/
├── raw/
│   ├── raw.csv          # Downloaded raw data 
│   ├── train.csv        # Training dataset
│   └── test.csv         # Testing dataset
└── processed/           # For preprocessed data
```

## Configuration

### config.yaml
```yaml
data_ingestion:
  bucket_name: "hotel-booking-mlops-data"
  bucket_file_name: "raw/hotel_bookings.csv"
  train_ratio: 0.8
```

### paths_config.py
```python
RAW_DIR = "artifacts/raw"
RAW_FILE_PATH = os.path.join(RAW_DIR, "raw.csv")
TRAIN_FILE_PATH = os.path.join(RAW_DIR, "train.csv")
TEST_FILE_PATH = os.path.join(RAW_DIR, "test.csv")
```

## Implementation

### DataIngestion Class
```python
class DataIngestion:
    def __init__(self, config):
        self.config = config["data_ingestion"]
        self.bucket_name = self.config["bucket_name"]
        self.file_name = self.config["bucket_file_name"]
        self.train_test_ratio = self.config["train_ratio"]
        
        os.makedirs(RAW_DIR, exist_ok=True)
        
    def download_csv_from_gcp(self):
        """Downloads dataset from GCP bucket"""
        try:
            client = storage.Client()
            bucket = client.bucket(self.bucket_name)
            blob = bucket.blob(self.file_name)
            blob.download_to_filename(RAW_FILE_PATH)
            logger.info(f"CSV file downloaded to {RAW_FILE_PATH}")
        except Exception as e:
            raise CustomException("Failed to download CSV", e)
            
    def split_data(self):
        """Splits data into training and testing sets"""
        try:
            data = pd.read_csv(RAW_FILE_PATH)
            train, test = train_test_split(
                data,
                test_size=1-self.train_test_ratio,
                random_state=42
            )
            train.to_csv(TRAIN_FILE_PATH, index=False)
            test.to_csv(TEST_FILE_PATH, index=False)
            logger.info("Data split completed successfully")
        except Exception as e:
            raise CustomException("Failed to split data", e)
            
    def run(self):
        """Executes the complete data ingestion pipeline"""
        try:
            self.download_csv_from_gcp()
            self.split_data()
            logger.info("Data ingestion completed successfully")
        except Exception as e:
            logger.error(f"Error in data ingestion: {str(e)}")
            raise e
```

## Quality Checks

### Data Validation
1. Schema Validation:
   - Data types match schema
   - Required columns present
   - No duplicate column names

2. Content Validation:
   - No empty files
   - Expected row count
   - Value ranges
   - Missing value checks

### Implementation
```python
def validate_data(data: pd.DataFrame) -> bool:
    """Validates the ingested data"""
    try:
        # Check required columns
        required_columns = set(schema.keys())
        if not required_columns.issubset(data.columns):
            missing = required_columns - set(data.columns)
            raise ValueError(f"Missing columns: {missing}")
            
        # Check data types
        for col, dtype in schema.items():
            if data[col].dtype.name != dtype:
                raise ValueError(f"Invalid dtype for {col}")
                
        # Check for nulls
        null_counts = data.isnull().sum()
        if null_counts.any():
            raise ValueError(f"Null values found: {null_counts[null_counts > 0]}")
            
        return True
        
    except Exception as e:
        logger.error(f"Data validation failed: {str(e)}")
        return False
```

## Error Handling

### Common Issues
1. GCP Authentication Errors
   - Missing credentials
   - Invalid permissions
   - Expired tokens

2. Data Download Issues
   - Network connectivity
   - File not found
   - Insufficient storage

3. Data Quality Issues
   - Corrupt files
   - Invalid format
   - Missing data

### Error Recovery
```python
def retry_download(max_attempts=3, delay=5):
    """Implements retry logic for downloads"""
    for attempt in range(max_attempts):
        try:
            return self.download_csv_from_gcp()
        except Exception as e:
            if attempt == max_attempts - 1:
                raise e
            time.sleep(delay)
```

## Monitoring

### Metrics
1. Download success rate
2. Download time
3. File size validation
4. Row count validation
5. Split ratio accuracy

### Logging
```python
logger.info(f"Starting download from {self.bucket_name}/{self.file_name}")
logger.info(f"Downloaded {os.path.getsize(RAW_FILE_PATH)} bytes")
logger.info(f"Train set: {len(train)} rows, Test set: {len(test)} rows")
```

## Testing

### Unit Tests
```python
def test_data_ingestion():
    """Tests the data ingestion pipeline"""
    config = read_yaml("config/config.yaml")
    ingestion = DataIngestion(config)
    
    # Test download
    ingestion.download_csv_from_gcp()
    assert os.path.exists(RAW_FILE_PATH)
    
    # Test split
    ingestion.split_data()
    assert os.path.exists(TRAIN_FILE_PATH)
    assert os.path.exists(TEST_FILE_PATH)
```

## Troubleshooting Guide

1. Authentication Issues
   - Verify GOOGLE_APPLICATION_CREDENTIALS
   - Check service account permissions
   - Validate bucket access

2. Download Failures
   - Check network connectivity
   - Verify file exists in bucket
   - Check storage space

3. Data Quality Issues
   - Validate file format
   - Check for corrupted data
   - Verify column names and types