pipeline {
      agent any

      environment {
        VENV_DIR = 'venv'  // Virtual environment directory
      }

      stages {
            stage('Cloning Git repo to Jenkins') {
            steps {
                  echo 'Cloning Git repository to Jenkins...'
                  git branch: 'main',
                        credentialsId: 'GitHub-Token',
                        url: 'https://github.com/AbulFaizBangi/MLOps-Project-1.git'
            }
            }

            stage('Set up Virtual Environment & Install Dependencies') {
            steps {
                  echo 'Creating Virtual Environment and Installing Dependencies using uv...'
                  sh(script: '''
                  #!/bin/bash
                  set -e

                  # Create and activate virtual environment
                  python3 -m venv "$VENV_DIR"
                  source "$VENV_DIR/bin/activate"

                  # Install dependencies from pyproject.toml using uv
                  uv install
                  ''')
            }
            }

            stage('Verify Installations') {
            steps {
                  echo 'Verifying installations...'
                  sh(script: '''
                  #!/bin/bash
                  set -e

                  source "$VENV_DIR/bin/activate"
                  echo "-- Python --"
                  python --version

                  echo "-- pip --"
                  pip --version

                  echo "-- uv CLI --"
                  uv --version
                  ''')
            }
            }
      }
}
