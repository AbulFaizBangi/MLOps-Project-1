pipeline {
      agent any

      environment {
            VENV_DIR    = 'venv'
            GCP_PROJECT = "basic-campus-458314-q7"
            GCLOUD_PATH = "/var/jenkins_home/google-cloud-sdk/bin"
      }

      stages {
            stage('Prepare Python') {
                  steps {
                  echo 'Ensuring python3-venv support is installed...'
                  sh '''
                        apt-get update
                        apt-get install -y python3.11-venv
                        ln -sf /usr/bin/python3 /usr/bin/python
                  '''
                  }
            }

            stage('Cloning Git repo to Jenkins') {
                  steps {
                  echo 'Cloning Git repository to Jenkins .....'
                  git branch: 'main',
                        credentialsId: 'GitHub-Token',
                        url: 'https://github.com/AbulFaizBangi/MLOps-Project-1.git'
                  }
            }

            stage('Check Python Version') {
                  steps {
                  echo "Checking Python version compatibility..."
                  script {
                        def pythonVersion = sh(script: 'python3 --version', returnStdout: true).trim()
                        echo "Current Python version: ${pythonVersion}"
                  }
                  sh '''
                        if [ -f pyproject.toml ]; then
                              sed -i 's/requires-python = ">=3.13"/requires-python = ">=3.11"/g' pyproject.toml
                              echo "Modified pyproject.toml to accept Python 3.11+"
                        fi
                  '''
                  }
            }

            stage('Setting up Virtual Environment and Installing dependencies') {
                  steps {
                  echo 'Setting up Virtual Environment and Installing dependencies............'
                  sh '''
                        python3 -m venv ${VENV_DIR}
                        . ${VENV_DIR}/bin/activate
                        pip install --upgrade pip
                        pip install -e .
                  '''
                  }
            }

            stage('Building and Pushing Docker Image to GCR') {
                  steps {
                  withCredentials([file(credentialsId: 'gcp-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                        echo 'Building and Pushing Docker Image to GCR.............'
                        sh '''
                              export PATH=$PATH:${GCLOUD_PATH}
                              chmod +x ${GCLOUD_PATH}/gcloud

                              gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}
                              gcloud config set project ${GCP_PROJECT}
                              gcloud auth configure-docker --quiet

                              docker build -t gcr.io/${GCP_PROJECT}/ml-project:latest .
                              docker push gcr.io/${GCP_PROJECT}/ml-project:latest
                        '''
                  }
                  }
            }

            stage('Push Docker Image to DockerHub') {
                  steps {
                  withCredentials([usernamePassword(
                        credentialsId: 'DockerHub-Creds',
                        usernameVariable: 'DOCKERHUB_USERNAME',
                        passwordVariable: 'DOCKERHUB_PASSWORD'
                  )]) {
                        echo 'Pushing Docker Image to DOCKERHUB.............'
                        sh '''
                              echo ${DOCKERHUB_PASSWORD} | docker login -u ${DOCKERHUB_USERNAME} --password-stdin
                              docker tag gcr.io/${GCP_PROJECT}/ml-project:latest ${DOCKERHUB_USERNAME}/ml-project:latest
                              docker push ${DOCKERHUB_USERNAME}/ml-project:latest
                              docker logout
                        '''
                  }
                  }
            }

            stage('Deploy to GCP Cloud Run') {
                  steps {
                  withCredentials([file(credentialsId: 'gcp-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                        echo 'Deploying to GCP Cloud Run.............'
                        sh '''
                              export PATH=$PATH:${GCLOUD_PATH}
                              chmod +x ${GCLOUD_PATH}/gcloud

                              ${GCLOUD_PATH}/gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}
                              ${GCLOUD_PATH}/gcloud config set project ${GCP_PROJECT}

                              ${GCLOUD_PATH}/gcloud run deploy ml-project \
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
                  echo 'Pipeline finished with status: ' + currentBuild.currentResult
            }
      }
}
