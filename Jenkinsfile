pipeline {
  agent any

  stages {
    stage('Build Spring Boot') {
      agent {
        docker { image 'maven:3.8.6-jdk-8' }
      }
      steps {
        dir('spring-boot-server') {
          sh 'mvn clean package -DskipTests'
        }
      }
    }

    stage('Build Angular') {
      agent {
        docker { image 'node:18' }
      }
      steps {
        dir('angular-16-client') {
          sh 'npm install'
          sh 'npm run build --prod'
        }
      }
    }

    stage('Build Docker Images') {
      agent {
        docker {
          image 'docker:latest'
          args '--privileged -v /var/run/docker.sock:/var/run/docker.sock'
        }
      }
      steps {
        script {
          sh 'docker build -t spring-boot-server:latest ./spring-boot-server'
          sh 'docker build -t angular-client:latest ./angular-16-client'
        }
      }
    }

    stage('Deploy to Minikube') {
      agent {
        docker { image 'bitnami/kubectl:latest' }
      }
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
