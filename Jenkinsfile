pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/Essra-Hmida/testing-sa-copy.git'
            }
        }

        stage('Build Spring Boot') {
            steps {
                dir('spring-boot-server') {
                    sh 'mvn clean package -DskipTests'
                }
            }
        }

        stage('Build Angular') {
            steps {
                dir('angular-16-client') {
                    sh 'npm install'
                    sh 'npm run build --prod'
                }
            }
        }
    }
}
