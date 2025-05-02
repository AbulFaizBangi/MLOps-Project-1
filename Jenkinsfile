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
                sh '''#!/bin/bash
                # Create virtual environment
                python3 -m venv ${VENV_DIR}
                
                # Use . instead of source for better shell compatibility
                . ${VENV_DIR}/bin/activate
                
                # Make sure the virtual environment is working
                which python
                
                # Install dependencies from pyproject.toml using uv
                uv install
                '''
            }
        }

        stage('Verify Installations') {
            steps {
                echo 'Verifying installations...'
                sh '''#!/bin/bash
                # Use . instead of source for better shell compatibility
                . ${VENV_DIR}/bin/activate
                
                echo "-- Python --"
                python --version
                
                echo "-- pip --"
                pip --version
                
                echo "-- uv CLI --"
                uv --version
                '''
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Please check the logs for details.'
        }
        always {
            echo 'Cleaning up workspace...'
        }
    }
}