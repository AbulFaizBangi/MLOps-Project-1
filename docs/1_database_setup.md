# Database Setup

## Overview
This document outlines the setup and configuration of our data storage infrastructure using Google Cloud Platform (GCP) services.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [GCP Setup](#gcp-setup)
3. [Storage Configuration](#storage-configuration)
4. [BigQuery Integration](#bigquery-integration)
5. [Authentication](#authentication)
6. [Python Integration](#python-integration)

## Prerequisites
- GCP Account with billing enabled
- `gcloud` CLI installed
- Python 3.8+
- Required Python packages: `google-cloud-storage`, `google-cloud-bigquery`

## GCP Setup
1. Create a new GCP project:
   ```bash
   gcloud projects create hotel-booking-mlops
   gcloud config set project hotel-booking-mlops
   ```

2. Enable required APIs:
   ```bash
   gcloud services enable storage.googleapis.com bigquery.googleapis.com
   ```

## Storage Configuration

### Google Cloud Storage Setup
1. Create storage bucket:
   ```bash
   gcloud storage buckets create gs://hotel-booking-mlops-data \
       --location=us-central1 \
       --uniform-bucket-level-access
   ```

2. Bucket structure:
   ```
   hotel-booking-mlops-data/
   ├── raw/
   │   └── hotel_bookings.csv
   ├── processed/
   │   ├── train.csv
   │   └── test.csv
   └── models/
       └── model_artifacts/
   ```

## BigQuery Integration

1. Create dataset:
   ```bash
   bq mk --dataset \
       --description "Hotel Booking MLOps Dataset" \
       --location us-central1 \
       hotel_booking_mlops
   ```

2. Dataset structure:
   - Raw bookings table
   - Processed features table
   - Model predictions table

## Authentication

1. Create service account:
   ```bash
   gcloud iam service-accounts create mlops-service-account \
       --description="MLOps Pipeline Service Account" \
       --display-name="MLOps Service Account"
   ```

2. Generate and download key:
   ```bash
   gcloud iam service-accounts keys create key.json \
       --iam-account=mlops-service-account@hotel-booking-mlops.iam.gserviceaccount.com
   ```

3. Set environment variable:
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="path/to/key.json"
   ```

## Python Integration

### Storage Client Setup
```python
from google.cloud import storage

def setup_gcp_storage():
    storage_client = storage.Client()
    bucket = storage_client.bucket('hotel-booking-mlops-data')
    return bucket

def upload_file(bucket, source_file, destination_blob):
    blob = bucket.blob(destination_blob)
    blob.upload_from_filename(source_file)
```

### BigQuery Client Setup
```python
from google.cloud import bigquery

def setup_bigquery():
    client = bigquery.Client()
    dataset_ref = client.dataset('hotel_booking_mlops')
    return client, dataset_ref

def create_booking_table(client, dataset_ref):
    schema = [
        bigquery.SchemaField("booking_id", "STRING"),
        bigquery.SchemaField("lead_time", "INTEGER"),
        # Add other fields as needed
    ]
    table_ref = dataset_ref.table("bookings")
    table = bigquery.Table(table_ref, schema=schema)
    client.create_table(table)
```

## Security Considerations
- Enable Cloud KMS for encryption
- Set up IAM roles with least privilege
- Enable Cloud Audit Logging
- Implement VPC Service Controls

## Monitoring and Maintenance
1. Set up monitoring:
   - Storage metrics
   - BigQuery query performance
   - Cost monitoring

2. Regular maintenance:
   - Data cleanup
   - Access review
   - Backup verification

## Troubleshooting
Common issues and solutions:
1. Authentication errors:
   - Verify service account permissions
   - Check GOOGLE_APPLICATION_CREDENTIALS path
2. Storage access issues:
   - Verify bucket permissions
   - Check network connectivity
3. BigQuery errors:
   - Validate query syntax
   - Check dataset location