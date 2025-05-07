"""Google Cloud Platform configuration settings."""

GCP_CONFIG = {
    'project_id': 'hotel-booking-mlops',  # Replace with your actual GCP project ID
    'bucket_name': 'hotel-booking-mlops-data',
    'dataset_id': 'hotel_booking_mlops',
    'location': 'us-central1',
    'storage_class': 'STANDARD',
    'raw_data_prefix': 'raw/',
    'processed_data_prefix': 'processed/',
    'model_artifacts_prefix': 'models/'
}

# BigQuery table configurations
BIGQUERY_CONFIG = {
    'booking_table': 'hotel_bookings',
    'schema': [
        {'name': 'hotel', 'type': 'STRING'},
        {'name': 'is_canceled', 'type': 'INTEGER'},
        {'name': 'lead_time', 'type': 'INTEGER'},
        {'name': 'arrival_date_year', 'type': 'INTEGER'},
        {'name': 'arrival_date_month', 'type': 'STRING'},
        {'name': 'arrival_date_week_number', 'type': 'INTEGER'},
        {'name': 'arrival_date_day_of_month', 'type': 'INTEGER'},
        {'name': 'stays_in_weekend_nights', 'type': 'INTEGER'},
        {'name': 'stays_in_week_nights', 'type': 'INTEGER'},
        {'name': 'adults', 'type': 'INTEGER'},
        {'name': 'children', 'type': 'INTEGER'},
        {'name': 'babies', 'type': 'INTEGER'},
        {'name': 'meal', 'type': 'STRING'},
        {'name': 'country', 'type': 'STRING'},
        {'name': 'market_segment', 'type': 'STRING'},
        {'name': 'distribution_channel', 'type': 'STRING'},
        {'name': 'is_repeated_guest', 'type': 'INTEGER'},
        {'name': 'previous_cancellations', 'type': 'INTEGER'},
        {'name': 'previous_bookings_not_canceled', 'type': 'INTEGER'},
        {'name': 'reserved_room_type', 'type': 'STRING'},
        {'name': 'assigned_room_type', 'type': 'STRING'},
        {'name': 'booking_changes', 'type': 'INTEGER'},
        {'name': 'deposit_type', 'type': 'STRING'},
        {'name': 'agent', 'type': 'STRING'},
        {'name': 'company', 'type': 'STRING'},
        {'name': 'days_in_waiting_list', 'type': 'INTEGER'},
        {'name': 'customer_type', 'type': 'STRING'},
        {'name': 'adr', 'type': 'FLOAT'},
        {'name': 'required_car_parking_spaces', 'type': 'INTEGER'},
        {'name': 'total_of_special_requests', 'type': 'INTEGER'},
        {'name': 'reservation_status', 'type': 'STRING'},
        {'name': 'reservation_status_date', 'type': 'DATE'}
    ]
}