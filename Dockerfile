# Dockerfile for MLOps Project-1
# This Dockerfile builds a container for serving a LightGBM model with Flask
# Uses multi-stage build for efficiency and smaller final image

# ---- Build Stage ----
FROM python:3.10-slim as builder

      # Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
      PYTHONUNBUFFERED=1 \
      PIP_NO_CACHE_DIR=1 \
      PIP_DISABLE_PIP_VERSION_CHECK=1
      
      # Set the working directory
WORKDIR /build
      
      # Install build dependencies for LightGBM
RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential \
      libgomp1 \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*
      
      # Copy only the dependency files first for better caching
COPY pyproject.toml setup.cfg setup.py ./
      # If you have a requirements.txt file, add it here
      # COPY requirements.txt .
      
      # Install dependencies in a virtual environment
RUN python -m venv /venv
RUN /venv/bin/pip install --upgrade pip setuptools wheel
RUN /venv/bin/pip install -e .
      
      # ---- Final Stage ----
FROM python:3.10-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
      PYTHONUNBUFFERED=1
      
      # Set the working directory
WORKDIR /app
      
      # Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
      libgomp1 \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*
      
      # Copy the virtual environment from the builder stage
COPY --from=builder /venv /venv
      
      # Add the virtual environment to PATH
ENV PATH="/venv/bin:$PATH"
      
      # Copy only the necessary application files
COPY application.py .
COPY pipeline ./pipeline
COPY models ./models
      # Add any other necessary directories or files
      
      # Create a non-root user for security
RUN useradd -m appuser
RUN chown -R appuser:appuser /app
USER appuser
      
      # Train the model or copy pretrained model
      # Note: Only uncomment if you want to train model during build
      # RUN python pipeline/training_pipeline.py
      
      # Expose the port that Flask will run on
EXPOSE 5000
      
      # Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
      CMD curl -f http://localhost:5000/health || exit 1
      
      # Command to run the app
CMD ["python", "application.py"]