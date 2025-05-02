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
                        sh(script: '''
                              #!/bin/bash
                              set -e

                              # Create virtual environment
                              python3 -m venv $VENV_DIR

                              # Activate environment
                              . $VENV_DIR/bin/activate

                              # Upgrade pip and install uv
                              pip install --upgrade pip
                              pip install uv

                              # Use uv to install from pyproject.toml
                              uv pip install --system --require-virtualenv
                        ''', shell: '/bin/bash')
                  }
                  }
            }
      }
      }
