pipeline {
    agent any

    environment {
        VENV_DIR    = 'venv'
        GCP_PROJECT = 'basic-campus-458314-q7'
        // gcloud already in PATH inside the container
    }

    stages {
        stage('Checkout') {
            steps {
                echo '🔄 Checking out source…'
                git branch:      'main',
                    credentialsId: 'GitHub-Token',
                    url:           'https://github.com/AbulFaizBangi/MLOps-Project-1.git'
            }
        }

        stage('Build & Deploy Inside gcloud SDK Container') {
            steps {
                script {
                    // pull the official gcloud SDK image (includes docker CLI + Python3/VENV)
                    def sdk = docker.image('google/cloud-sdk:slim')
                    sdk.pull()

                    // run _everything_ inside that container as root
                    sdk.inside('-u root:root') {
                        // 1) Verify Python
                        sh 'python3 --version'

                        // 2) Update pyproject.toml if needed
                        sh '''
                          if [ -f pyproject.toml ]; then
                            sed -i 's/requires-python = ">=3.13"/requires-python = ">=3.11"/g' pyproject.toml
                            echo "✔ pyproject.toml adjusted"
                          fi
                        '''

                        // 3) Create virtualenv + install
                        sh '''
                          python3 -m venv ${VENV_DIR}
                          . ${VENV_DIR}/bin/activate
                          pip install --upgrade pip
                          pip install -e .
                        '''

                        // 4) Build & push to GCR
                        withCredentials([file(
                          credentialsId: 'gcp-key',
                          variable:      'GOOGLE_APPLICATION_CREDENTIALS'
                        )]) {
                          sh '''
                            gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}
                            gcloud config set project ${GCP_PROJECT}
                            gcloud auth configure-docker --quiet
                            docker build -t gcr.io/${GCP_PROJECT}/ml-project:latest .
                            docker push gcr.io/${GCP_PROJECT}/ml-project:latest
                          '''
                        }

                        // 5) Push to DockerHub
                        withCredentials([usernamePassword(
                          credentialsId:    'DockerHub-Creds',
                          usernameVariable: 'DOCKERHUB_USERNAME',
                          passwordVariable: 'DOCKERHUB_PASSWORD'
                        )]) {
                          sh '''
                            echo ${DOCKERHUB_PASSWORD} | docker login -u ${DOCKERHUB_USERNAME} --password-stdin
                            docker tag gcr.io/${GCP_PROJECT}/ml-project:latest ${DOCKERHUB_USERNAME}/ml-project:latest
                            docker push ${DOCKERHUB_USERNAME}/ml-project:latest
                            docker logout
                          '''
                        }

                        // 6) Deploy to Cloud Run
                        withCredentials([file(
                          credentialsId: 'gcp-key',
                          variable:      'GOOGLE_APPLICATION_CREDENTIALS'
                        )]) {
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
        }
    }

    post {
        always {
            echo "🔔 Pipeline finished with status: ${currentBuild.currentResult}"
        }
    }
}
