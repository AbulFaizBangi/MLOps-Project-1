# Use a lightweight Python base image
FROM python:3.10-slim

# Prevent Python from writing .pyc files and ensure stdout/stderr are flushed immediately
ENV PYTHONDONTWRITEBYTECODE=1 \
      PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# Install system dependencies required by LightGBM and Uvicorn
RUN apt-get update \
      && apt-get install -y --no-install-recommends libgomp1 \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*

# Copy application code
COPY . .

# Create output directories early (avoids permissions issues later)
RUN mkdir -p artifacts/models \
      && mkdir -p $(dirname $(python -c "from config.paths_config import MODEL_OUTPUT_PATH; print(MODEL_OUTPUT_PATH)"))

# Use 'uv' for package installation if that's your custom installer
# Otherwise fallback to pip. Assumes 'uv' is available in this environment.
RUN uv install --no-cache-dir -e .

# Copy a pre-trained model if provided
COPY lgbm_model.pkl artifacts/models/

# Train model at build time to ensure the pipeline works
RUN python pipeline/training_pipeline.py \
      && python -c "import os; from config.paths_config import MODEL_OUTPUT_PATH; assert os.path.exists(MODEL_OUTPUT_PATH), f'Model file not found at {MODEL_OUTPUT_PATH}'"

# Expose port (Cloud Run overrides but makes intent clear)
EXPOSE 8080

# Start with Gunicorn and Uvicorn worker for asynchronous support
CMD ["gunicorn", "--bind", ":$PORT", "--workers", "1", "--threads", "8", "--timeout", "0", "-k", "uvicorn.workers.UvicornWorker", "app:app"]
