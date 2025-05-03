pipeline {
      agent any

      environment {
            VENV_DIR = 'venv'
            PYTHON_VERSION = sh(script: 'python --version', returnStdout: true).trim()
            GCP_PROJECT = "basic-campus-458314-q7"
            GCLOUD_PATH = "/var/jenkins_home/google-cloud-sdk/bin"
      }

      stages {
            stage('Cloning Git repo to Jenkins') {
                  steps {
                  script {
                        echo 'Cloning Git repository to Jenkins .....'
                        git branch: 'main',
                              credentialsId: 'GitHub-Token',
                              url: 'https://github.com/AbulFaizBangi/MLOps-Project-1.git'
                  }
                  }
            }

      stage('Check Python Version') {
            steps {
                  script {
                        echo "Current Python version: ${PYTHON_VERSION}"
                        echo "Checking Python version compatibility..."
                        
                        // Update pyproject.toml to work with the available Python version
                        sh '''
                              if [ -f pyproject.toml ]; then
                              sed -i 's/requires-python = ">=3.13"/requires-python = ">=3.11"/g' pyproject.toml
                              echo "Modified pyproject.toml to accept Python 3.11+"
                              fi
                        '''
                  }
                  }
            }

      stage('Setting up Virtual Environment and Installing dependencies') {
            steps {
                  script {
                        echo 'Setting up Virtual Environment and Installing dependencies............'
                        sh '''
                              python -m venv ${VENV_DIR}
                              . ${VENV_DIR}/bin/activate
                              pip install --upgrade pip
                              pip install -e .
                        '''
                  }
                  }
            }
      stage('Building and Pushing Docker Image to GCR'){
            steps{
                  withCredentials([file(credentialsId: 'gcp-key' , variable : 'GOOGLE_APPLICATION_CREDENTIALS')]){
                        script{
                              echo 'Building and Pushing Docker Image to GCR.............'
                              sh '''
                              export PATH=$PATH:${GCLOUD_PATH}

                              gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}

                              gcloud config set project ${GCP_PROJECT}

                              gcloud auth configure-docker --quiet

                              docker build -t gcr.io/${GCP_PROJECT}/ml-project:latest .

                              docker push gcr.io/${GCP_PROJECT}/ml-project:latest 

                              '''
                              }
                        }
                  }
            }
      }
}