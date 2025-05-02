pipeline {
      agent any

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

            stage('Setting up Virtual Environment and Installing Dependencies') {
                  steps {
                  script {
                        echo 'Setting up Virtual Environment and Installing Dependencies .....'
                        
                        // Approach 1: Use dot instead of source
                        sh '''
                        python3 -m venv ${VENV_DIR}
                        . ${VENV_DIR}/bin/activate
                        pip install --upgrade pip
                        pip install uv
                        
                        # If you have a requirements.txt file
                        if [ -f "requirements.txt" ]; then
                              uv pip install -r requirements.txt
                        fi
                        
                        # If you have a pyproject.toml file
                        if [ -f "pyproject.toml" ]; then
                              uv pip install -e .
                        fi
                        '''
                        
                        // If the above fails, uncomment this alternative approach
                        /*
                        sh '''
                              python3 -m venv ${VENV_DIR}
                              ${VENV_DIR}/bin/pip install --upgrade pip
                              ${VENV_DIR}/bin/pip install uv
                              ${VENV_DIR}/bin/uv install
                        '''
                        */
                  }
                  }
            }
      }
      }
