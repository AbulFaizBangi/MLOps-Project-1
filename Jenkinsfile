pipeline {
    agent any

    environment {
        VENV_DIR = 'venv'
        GCP_PROJECT = "basic-campus-458314-q7"
        GCLOUD_PATH = "/var/jenkins_home/google-cloud-sdk/bin"
        
        // Configure proxy if needed (uncomment and set these variables if behind a proxy)
        // http_proxy = "http://proxy.example.com:8080"
        // https_proxy = "http://proxy.example.com:8080"
        // no_proxy = "localhost,127.0.0.1"
    }

    stages {
        stage('Network Connectivity Check') {
            steps {
                script {
                    echo 'Checking DNS and network configuration...'
                    sh '''
                        echo "==== Network Configuration ===="
                        cat /etc/resolv.conf || echo "Could not read DNS configuration"
                        echo
                        
                        echo "==== Testing GitHub connectivity ===="
                        curl -v --connect-timeout 10 https://api.github.com || echo "GitHub connectivity test failed"
                        echo
                    '''
                }
            }
        }
        
        stage('Cloning Git repo to Jenkins') {
            steps {
                script {
                    echo 'Cloning Git repository to Jenkins .....'
                    // Configure Git to use HTTP instead of DNS resolution
                    sh 'git config --global http.sslVerify false'
                    
                    // Try with IP address in case of DNS issues
                    retry(3) {
                        timeout(time: 2, unit: 'MINUTES') {
                            catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                                try {
                                    git branch: 'main',
                                        credentialsId: 'GitHub-Token',
                                        url: 'https://github.com/AbulFaizBangi/MLOps-Project-1.git'
                                } catch (Exception e) {
                                    echo "Trying alternative connection method..."
                                    // Try with IP address (GitHub IPs can change, this is an example)
                                    sh 'mkdir -p temp_repo'
                                    dir('temp_repo') {
                                        sh 'git init'
                                        sh 'git remote add origin https://github.com/AbulFaizBangi/MLOps-Project-1.git'
                                        sh 'git fetch --depth 1 origin main'
                                        sh 'git checkout FETCH_HEAD'
                                    }
                                    sh 'cp -r temp_repo/. .'
                                    sh 'rm -rf temp_repo'
                                }
                            }
                        }
                    }
                }
            }
        }

        stage('Check Python Version') {
            steps {
                script {
                    echo "Checking Python version compatibility..."
                    def pythonVersion = sh(script: 'python3 --version || python --version', returnStdout: true).trim()
                    echo "Current Python version: ${pythonVersion}"

                    sh '''
                        if [ -f pyproject.toml ]; then
                            sed -i 's/requires-python = ">=3.13"/requires-python = ">=3.11"/g' pyproject.toml
                            echo "Modified pyproject.toml to accept Python 3.11+"
                        fi
                    '''
                }
            }
        }

        stage('Setup Virtual Environment') {
            steps {
                echo 'Setting up Virtual Environment and Installing dependencies............'
                sh '''
                    python3 -m venv ${VENV_DIR} || python -m venv ${VENV_DIR}
                    . ${VENV_DIR}/bin/activate
                    pip install --upgrade pip
                    
                    # Add timeout and retry for pip install
                    pip install --default-timeout=100 -e . || pip install --default-timeout=100 -e .
                '''
            }
        }

        stage('Building and Pushing Docker Image to GCR') {
            steps {
                withCredentials([file(credentialsId: 'gcp-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    echo 'Building and Pushing Docker Image to GCR.............'
                    sh '''
                        export PATH=$PATH:${GCLOUD_PATH}
                        chmod +x ${GCLOUD_PATH}/gcloud || echo "gcloud not found at specified path"
                        
                        # Verify the gcloud command exists
                        which gcloud || (echo "gcloud not found in PATH" && exit 1)
                        
                        # Use actual gcloud path found in the system
                        GCLOUD_CMD=$(which gcloud)
                        
                        $GCLOUD_CMD auth activate-service-account --key-file="${GOOGLE_APPLICATION_CREDENTIALS}"
                        $GCLOUD_CMD config set project ${GCP_PROJECT}
                        $GCLOUD_CMD auth configure-docker --quiet

                        # Add retry mechanism for docker push
                        MAX_ATTEMPTS=3
                        ATTEMPT=1
                        
                        docker build -t gcr.io/${GCP_PROJECT}/ml-project:latest .
                        
                        while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
                            echo "Docker push attempt $ATTEMPT of $MAX_ATTEMPTS"
                            if docker push gcr.io/${GCP_PROJECT}/ml-project:latest; then
                                echo "Docker push successful!"
                                break
                            else
                                ATTEMPT=$((ATTEMPT+1))
                                if [ $ATTEMPT -le $MAX_ATTEMPTS ]; then
                                    echo "Docker push failed, retrying in 10 seconds..."
                                    sleep 10
                                else
                                    echo "Docker push failed after $MAX_ATTEMPTS attempts"
                                    exit 1
                                fi
                            fi
                        done
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
                    echo 'Pushing Docker Image to DockerHub.............'
                    sh '''
                        echo ${DOCKERHUB_PASSWORD} | docker login -u ${DOCKERHUB_USERNAME} --password-stdin
                        docker tag gcr.io/${GCP_PROJECT}/ml-project:latest ${DOCKERHUB_USERNAME}/ml-project:latest
                        
                        # Add retry for Docker Hub push
                        MAX_ATTEMPTS=3
                        ATTEMPT=1
                        
                        while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
                            echo "DockerHub push attempt $ATTEMPT of $MAX_ATTEMPTS"
                            if docker push ${DOCKERHUB_USERNAME}/ml-project:latest; then
                                echo "DockerHub push successful!"
                                break
                            else
                                ATTEMPT=$((ATTEMPT+1))
                                if [ $ATTEMPT -le $MAX_ATTEMPTS ]; then
                                    echo "DockerHub push failed, retrying in 10 seconds..."
                                    sleep 10
                                else
                                    echo "DockerHub push failed after $MAX_ATTEMPTS attempts"
                                    exit 1
                                fi
                            fi
                        done
                        
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
                        
                        # Use actual gcloud path found in the system
                        GCLOUD_CMD=$(which gcloud || echo "${GCLOUD_PATH}/gcloud")
                        chmod +x $GCLOUD_CMD || echo "Could not make gcloud executable"

                        $GCLOUD_CMD auth activate-service-account --key-file="${GOOGLE_APPLICATION_CREDENTIALS}"
                        $GCLOUD_CMD config set project ${GCP_PROJECT}

                        # Add retry for Cloud Run deployment
                        MAX_ATTEMPTS=3
                        ATTEMPT=1
                        
                        while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
                            echo "Cloud Run deploy attempt $ATTEMPT of $MAX_ATTEMPTS"
                            if $GCLOUD_CMD run deploy ml-project \\
                                --image=gcr.io/${GCP_PROJECT}/ml-project:latest \\
                                --platform=managed \\
                                --region=us-central1 \\
                                --allow-unauthenticated \\
                                --timeout=300s; then
                                echo "Cloud Run deployment successful!"
                                break
                            else
                                ATTEMPT=$((ATTEMPT+1))
                                if [ $ATTEMPT -le $MAX_ATTEMPTS ]; then
                                    echo "Cloud Run deployment failed, retrying in 30 seconds..."
                                    sleep 30
                                else
                                    echo "Cloud Run deployment failed after $MAX_ATTEMPTS attempts"
                                    exit 1
                                fi
                            fi
                        done
                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            script {
                echo 'Pipeline failed. Collecting diagnostic information...'
                sh '''
                    echo "=== Network Diagnostics ==="
                    echo "DNS Configuration:"
                    cat /etc/resolv.conf || echo "Could not read DNS configuration"
                    
                    echo "DNS Resolution Test:"
                    nslookup github.com || echo "DNS resolution failed"
                    
                    echo "Network Route Test:"
                    ip route || echo "Could not get route information"
                    
                    echo "HTTP Connection Test:"
                    curl -v --connect-timeout 5 https://github.com || echo "HTTP connection failed"
                    
                    echo "=== Environment Information ==="
                    env
                    
                    echo "=== Docker Information ==="
                    docker info || echo "Docker info not available"
                    
                    echo "=== System Information ==="
                    uname -a
                    cat /etc/os-release || echo "OS information not available"
                '''
                echo 'Please check the network connectivity and DNS configuration on your Jenkins server.'
            }
        }
    }
}