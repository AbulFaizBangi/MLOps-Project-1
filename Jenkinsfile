pipeline {
  // Use the official gcloud image (Debian-slim + Python3 + gcloud SDK)
      agent  {
      docker {
            image 'google/cloud-sdk:slim'
            // Run as root so we can pip-install if needed
            args '-u root:root'
      }
      }

      environment {
      VENV_DIR    = 'venv'
      GCP_PROJECT = 'basic-campus-458314-q7'
      // gcloud is already in PATH
      }

      stages {
      stage('Checkout') {
            steps {
            echo '🔄 Checking out source code...'
            git branch:      'main',
                  credentialsId: 'GitHub-Token',
                  url:           'https://github.com/AbulFaizBangi/MLOps-Project-1.git'
            }
      }

      stage('Inspect Python') {
            steps {
            echo '🐍 Verifying Python…'
            sh 'python3 --version'
            }
      }

      stage('Adjust pyproject.toml') {
            when { expression { fileExists('pyproject.toml') } }
            steps {
            echo '✏️  Updating requires-python…'
            sh '''
            sed -i \
                  's/requires-python = ">=3.13"/requires-python = ">=3.11"/g' \
                  pyproject.toml \
            && echo "✔ pyproject.toml updated for 3.11+"
            '''
            }
      }

      stage('Setup venv & Install') {
            steps {
            echo '⚙️  Creating virtualenv and installing…'
            sh '''
            python3 -m venv ${VENV_DIR}
            . ${VENV_DIR}/bin/activate
            pip install --upgrade pip
            pip install -e .
            '''
            }
      }

      stage('Build & Push to GCR') {
            steps {
            withCredentials([file(
            credentialsId: 'gcp-key',
            variable:      'GOOGLE_APPLICATION_CREDENTIALS'
            )]) {
            echo '📦 Building Docker image…'
            sh '''
                  gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}
                  gcloud config set project ${GCP_PROJECT}
                  gcloud auth configure-docker --quiet

                  docker build -t gcr.io/${GCP_PROJECT}/ml-project:latest .
                  docker push gcr.io/${GCP_PROJECT}/ml-project:latest
            '''
            }
            }
      }

      stage('Push to DockerHub') {
            steps {
            withCredentials([usernamePassword(
            credentialsId:      'DockerHub-Creds',
            usernameVariable:   'DOCKERHUB_USERNAME',
            passwordVariable:   'DOCKERHUB_PASSWORD'
            )]) {
            echo '🐳 Pushing to DockerHub…'
            sh '''
                  echo ${DOCKERHUB_PASSWORD} | docker login -u ${DOCKERHUB_USERNAME} --password-stdin
                  docker tag gcr.io/${GCP_PROJECT}/ml-project:latest ${DOCKERHUB_USERNAME}/ml-project:latest
                  docker push ${DOCKERHUB_USERNAME}/ml-project:latest
                  docker logout
            '''
            }
            }
      }

      stage('Deploy to Cloud Run') {
            steps {
            withCredentials([file(
            credentialsId: 'gcp-key',
            variable:      'GOOGLE_APPLICATION_CREDENTIALS'
            )]) {
            echo '🚀 Deploying to Cloud Run…'
            sh '''
                  gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}
                  gcloud config set project ${GCP_PROJECT}

                  gcloud run deploy ml-project \
                  --image=gcr.io/${GCP_PROJECT}/ml-project:latest \
                  --platform=managed \
                  --region=us-central1 \
                  --allow-unauthenticated \
                  --timeout=300s
            '''
            }
            }
      }
      }

      post {
      always {
            echo "🔔 Pipeline finished with status: ${currentBuild.currentResult}"
      }
      }
}
