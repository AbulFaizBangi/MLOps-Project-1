      pipeline {
      agent {
            docker {
                  image 'python:3.13-rc-slim'  // Use Python 3.13 RC image
                  args '-v $HOME/.cache:/root/.cache'  // Cache pip packages
            }
      }

      environment {
            VENV_DIR = 'venv'
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
            
            stage('Run Tests') {
                  steps {
                  script {
                        echo 'Running tests...'
                        sh '''
                        . ${VENV_DIR}/bin/activate
                        pytest
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
                  echo 'Pipeline executed successfully!'
            }
            failure {
                  echo 'Pipeline execution failed!'
            }
      }
      }