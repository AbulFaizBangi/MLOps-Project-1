pipeline{
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

            stage('Setting up our Virtual Environment and Installing dependancies'){
            steps{
                  script{
                        echo 'Setting up our Virtual Environment and Installing dependancies............'
                        sh '''
                        python -m venv ${VENV_DIR}
                        . ${VENV_DIR}/bin/activate
                        pip install --upgrade pip
                        pip install -e .
                        '''
            }
            }
            }
      }
}