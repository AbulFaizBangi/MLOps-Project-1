pipeline{
      agent any
      stages{
            stage ('Cloning Gitrep to jenkins'){
                  steps{
                        script{
                              echo 'Cloning Git repository to Jenkins'
                              checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'GitHub-Token', url: 'https://github.com/AbulFaizBangi/MLOps-Project-1.git']])
                              
                        }
                  }
            }
      }
}