pipeline {
  agent any

  stages {
    stage('Checkout') {
      steps {
        // Cloner depuis ton repo GitHub
        git url: 'https://github.com/Essra-Hmida/testing-sa-copy.git', branch: 'master'
      }
    }

    stage('Configure Docker for Minikube') {
      steps {
        script {
          if (isUnix()) {
            sh 'eval $(minikube -p minikube docker-env)'
          } else {
            powershell '''
              & minikube -p minikube docker-env --shell powershell | Invoke-Expression
            '''
          }
        }
      }
    }

    stage('Build Backend and Frontend') {
      parallel {
        stage('Build Spring Boot') {
          steps {
            dir('spring-boot-server') {
              sh 'mvn clean package -DskipTests'
            }
          }
        }

        stage('Build Angular App') {
          steps {
            dir('angular-16-client') {
              sh 'npm install'
              sh 'npm run build --prod'
            }
          }
        }
      }
    }

    stage('Build Docker Images (Minikube)') {
      steps {
        sh 'docker build -t spring-boot-server:latest ./spring-boot-server'
        sh 'docker build -t angular-client:latest ./angular-16-client'
      }
    }

    stage('Deploy on Minikube') {
      steps {
        sh '''
          kubectl apply -f mysql/k8s/ --validate=false
          kubectl apply -f phpmyadmin/k8s/ --validate=false
          kubectl apply -f spring-boot-server/k8s/ --validate=false
          kubectl apply -f angular-16-client/k8s/ --validate=false
          kubectl apply -f ingress/k8s/ --validate=false
        '''
      }
    }
  }
}
