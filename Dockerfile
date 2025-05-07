# Use a lightweight Python image
FROM python:slim

# Set environment variables to prevent Python from writing .pyc files & Ensure Python output is not buffered
ENV PYTHONDONTWRITEBYTECODE=1 \
      PYTHONUNBUFFERED=1

# Set the working directory
WORKDIR /app

# Install system dependencies required by LightGBM
RUN apt-get update && apt-get install -y --no-install-recommends \
      libgomp1 \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*

# Copy the application code
COPY . .

# Install the package in editable mode and Gunicorn
RUN pip install --no-cache-dir -e . gunicorn

# Create necessary directories for the model
RUN mkdir -p $(dirname $(python -c "from config.paths_config import MODEL_OUTPUT_PATH; print(MODEL_OUTPUT_PATH)"))


# Train the model before running the application
RUN python pipeline/training_pipeline.py && \
      python -c "import os; from config.paths_config import MODEL_OUTPUT_PATH; assert os.path.exists(MODEL_OUTPUT_PATH), f'Model file not found at {MODEL_OUTPUT_PATH}'"

# No need to explicitly expose the port - Cloud Run will handle this through env vars
# EXPOSE 8080

# Command to run the app
# CMD ["python", "application.py"]

# Use Gunicorn to serve the application
# This CMD will be overridden by the gcloud run deploy --command and --args flags:
CMD exec gunicorn --bind 0.0.0.0:$PORT --workers 1 --threads 8 --timeout 900 app:app
