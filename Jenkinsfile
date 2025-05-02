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
                        sh '''
                        #!/bin/bash
                        python3 -m venv $VENV_DIR
                        source $VENV_DIR/bin/activate
                        pip install --upgrade pip
                        poetry export -f requirements.txt --without-hashes --output requirements.txt
                        pip install -r requirements.txt
                        '''
                  }
                  }
            }
      }
}
