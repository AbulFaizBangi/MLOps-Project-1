# User Application

## Overview
This document details the Flask web application that serves the Hotel Booking Prediction model, providing a user-friendly interface for making predictions.

## Table of Contents
1. [Application Structure](#application-structure)
2. [Frontend Implementation](#frontend-implementation)
3. [Backend Implementation](#backend-implementation)
4. [API Endpoints](#api-endpoints)
5. [Error Handling](#error-handling)
6. [Deployment](#deployment)

## Application Structure

### Directory Layout
```
Project-1/
├── application.py        # Flask application
├── templates/           # HTML templates
│   ├── index.html      # Main prediction page
│   ├── result.html     # Prediction results
│   └── error.html      # Error page
├── static/             # Static assets
│   ├── style.css      # CSS styles
│   ├── script.js      # JavaScript code
│   └── images/        # Image assets
└── artifacts/
    └── models/        # Trained models
```

## Frontend Implementation

### HTML Templates
```html
<!-- templates/index.html -->
<!DOCTYPE html>
<html>
<head>
    <title>Hotel Booking Prediction</title>
    <link rel="stylesheet" href="{{ url_for('static', filename='style.css') }}">
</head>
<body>
    <div class="container">
        <h1>Hotel Booking Prediction</h1>
        <form method="POST" action="{{ url_for('predict') }}">
            <!-- Booking Details -->
            <div class="form-group">
                <label>Lead Time (days):</label>
                <input type="number" name="lead_time" required>
            </div>
            
            <!-- Room Information -->
            <div class="form-group">
                <label>Room Type:</label>
                <select name="room_type" required>
                    <option value="Room_Type 1">Type 1</option>
                    <option value="Room_Type 2">Type 2</option>
                    <option value="Room_Type 3">Type 3</option>
                </select>
            </div>
            
            <!-- Guest Information -->
            <div class="form-group">
                <label>Number of Adults:</label>
                <input type="number" name="no_of_adults" required>
            </div>
            
            <button type="submit">Predict</button>
        </form>
    </div>
</body>
</html>
```

### CSS Styling
```css
/* static/style.css */
body {
    font-family: 'Arial', sans-serif;
    line-height: 1.6;
    margin: 0;
    padding: 20px;
    background-color: #f4f4f4;
}

.container {
    max-width: 800px;
    margin: 0 auto;
    background: white;
    padding: 20px;
    border-radius: 5px;
    box-shadow: 0 0 10px rgba(0,0,0,0.1);
}

.form-group {
    margin-bottom: 15px;
}

.form-group label {
    display: block;
    margin-bottom: 5px;
    font-weight: bold;
}

input, select {
    width: 100%;
    padding: 8px;
    border: 1px solid #ddd;
    border-radius: 4px;
}

button {
    background: #007bff;
    color: white;
    padding: 10px 20px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
}

button:hover {
    background: #0056b3;
}
```

## Backend Implementation

### Flask Application
```python
from flask import Flask, render_template, request, jsonify
import joblib
import pandas as pd
from src.data_preprocessing import DataProcessor
from src.logger import logger
from src.custom_exception import CustomException

app = Flask(__name__)

# Load the model
MODEL_PATH = "artifacts/models/lgbm_model.pkl"
model = joblib.load(MODEL_PATH)
processor = DataProcessor()

@app.route('/')
def home():
    """Render the home page"""
    try:
        return render_template('index.html')
    except Exception as e:
        logger.error(f"Error rendering home page: {str(e)}")
        return render_template('error.html', error=str(e))

@app.route('/predict', methods=['POST'])
def predict():
    """Handle prediction requests"""
    try:
        # Get form data
        data = {
            'lead_time': int(request.form['lead_time']),
            'room_type': request.form['room_type'],
            'no_of_adults': int(request.form['no_of_adults'])
            # Add other features
        }
        
        # Create DataFrame
        df = pd.DataFrame([data])
        
        # Preprocess data
        processed_data = processor.process(df)
        
        # Make prediction
        prediction = model.predict(processed_data)[0]
        probability = model.predict_proba(processed_data)[0][1]
        
        return render_template(
            'result.html',
            prediction=prediction,
            probability=probability
        )
        
    except Exception as e:
        logger.error(f"Prediction error: {str(e)}")
        return render_template('error.html', error=str(e))

@app.route('/api/predict', methods=['POST'])
def predict_api():
    """API endpoint for predictions"""
    try:
        # Get JSON data
        data = request.json
        
        # Validate input
        if not all(key in data for key in ['lead_time', 'room_type', 'no_of_adults']):
            raise ValueError("Missing required fields")
        
        # Create DataFrame
        df = pd.DataFrame([data])
        
        # Preprocess and predict
        processed_data = processor.process(df)
        prediction = model.predict(processed_data)[0]
        probability = model.predict_proba(processed_data)[0][1]
        
        return jsonify({
            'prediction': int(prediction),
            'probability': float(probability),
            'status': 'success'
        })
        
    except Exception as e:
        logger.error(f"API error: {str(e)}")
        return jsonify({
            'error': str(e),
            'status': 'error'
        }), 400
```

## API Endpoints

### Prediction API
- Endpoint: `/api/predict`
- Method: POST
- Input Format:
  ```json
  {
      "lead_time": 45,
      "room_type": "Room_Type 1",
      "no_of_adults": 2,
      "no_of_children": 0,
      "no_of_weekend_nights": 1,
      "no_of_week_nights": 4,
      "type_of_meal_plan": "Meal Plan 1",
      "required_car_parking_space": 0,
      "market_segment_type": "Online",
      "repeated_guest": 0,
      "avg_price_per_room": 120.5,
      "no_of_special_requests": 1
  }
  ```
- Response Format:
  ```json
  {
      "prediction": 0,
      "probability": 0.23,
      "status": "success"
  }
  ```

## Error Handling

### Error Template
```html
<!-- templates/error.html -->
<!DOCTYPE html>
<html>
<head>
    <title>Error</title>
    <link rel="stylesheet" href="{{ url_for('static', filename='style.css') }}">
</head>
<body>
    <div class="container error">
        <h1>Error</h1>
        <p>{{ error }}</p>
        <a href="{{ url_for('home') }}" class="button">Back to Home</a>
    </div>
</body>
</html>
```

### Error Handling Middleware
```python
@app.errorhandler(404)
def not_found_error(error):
    return render_template('error.html', error="Page not found"), 404

@app.errorhandler(500)
def internal_error(error):
    logger.error(f"Server error: {str(error)}")
    return render_template('error.html', error="Internal server error"), 500
```

## Deployment

### Local Development
```bash
# Run Flask development server
flask run --debug
```

### Production Deployment
```python
if __name__ == '__main__':
    # Load configurations
    app.config.from_object('config.ProductionConfig')
    
    # Initialize monitoring
    setup_monitoring()
    
    # Run production server
    app.run(host='0.0.0.0', port=8080)
```

### Docker Deployment
```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY . .

RUN pip install -r requirements.txt

EXPOSE 8080
CMD ["python", "application.py"]
```

## Monitoring

### Application Metrics
```python
def setup_monitoring():
    """Setup application monitoring"""
    # Request timing
    @app.before_request
    def start_timer():
        g.start = time.time()

    @app.after_request
    def log_request(response):
        if request.path != '/metrics':
            duration = time.time() - g.start
            logger.info(f"Request to {request.path} took {duration:.2f}s")
        return response
```

### Error Tracking
```python
def log_prediction_error(error, input_data):
    """Log prediction errors for monitoring"""
    logger.error(
        "Prediction error",
        extra={
            'error_message': str(error),
            'input_data': input_data,
            'timestamp': datetime.now().isoformat()
        }
    )
```

## Testing

### Frontend Tests
```python
def test_home_page():
    """Test home page rendering"""
    with app.test_client() as client:
        response = client.get('/')
        assert response.status_code == 200
        assert b"Hotel Booking Prediction" in response.data
```

### API Tests
```python
def test_prediction_api():
    """Test prediction API endpoint"""
    with app.test_client() as client:
        response = client.post('/api/predict', json={
            'lead_time': 45,
            'room_type': 'Room_Type 1',
            'no_of_adults': 2
        })
        assert response.status_code == 200
        data = response.get_json()
        assert 'prediction' in data
        assert 'probability' in data
```

## Troubleshooting Guide

1. Application Issues
   - Check Flask logs
   - Verify model loading
   - Monitor memory usage
   - Test API endpoints

2. Model Issues
   - Validate input data
   - Check preprocessing
   - Monitor predictions
   - Review error logs

3. Performance Issues
   - Profile response times
   - Monitor resource usage
   - Check caching
   - Optimize queries