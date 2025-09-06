pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: maven
    image: maven:3.9.9-eclipse-temurin-17
    command:
    - cat
    tty: true
"""
        }
    }

    stages {
        stage('Checkout') {
            steps {
                // clone ton repo GitHub
                git branch: 'master', url: 'https://github.com/Essra-Hmida/testing-sa-copy.git'
            }
        }

        stage('Build Spring Boot') {
            steps {
                container('maven') {
                    // aller dans le dossier spring-boot-server et build
                    dir('spring-boot-server') {
                        sh 'mvn clean package -DskipTests'
                    }
                }
            }
        }
    }
}
