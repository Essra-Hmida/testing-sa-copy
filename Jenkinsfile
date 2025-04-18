pipeline {
    agent any
    
    environment {
        TAG = "${env.BUILD_NUMBER}"
        DOCKER_COMPOSE_FILE = "docker-compose.yml"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build Backend Image') {
            steps {
                dir('spring-boot-server') {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        bat "docker build -t %DOCKER_USERNAME%/spring-backend:%TAG% ."
                    }
                }
            }
        }
        
        stage('Build Frontend Image') {
            steps {
                dir('angular-16-client') {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        bat "docker build -t %DOCKER_USERNAME%/angular-frontend:%TAG% ."
                    }
                }
            }
        }
        
        stage('Push Images to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    bat "echo %DOCKER_PASSWORD%| docker login -u %DOCKER_USERNAME% --password-stdin"
                    bat "docker push %DOCKER_USERNAME%/spring-backend:%TAG%"
                    bat "docker push %DOCKER_USERNAME%/angular-frontend:%TAG%"
                    
                    // Also tag and push as latest
                    bat "docker tag %DOCKER_USERNAME%/spring-backend:%TAG% %DOCKER_USERNAME%/spring-backend:latest"
                    bat "docker tag %DOCKER_USERNAME%/angular-frontend:%TAG% %DOCKER_USERNAME%/angular-frontend:latest"
                    bat "docker push %DOCKER_USERNAME%/spring-backend:latest"
                    bat "docker push %DOCKER_USERNAME%/angular-frontend:latest"
                }
            }
        }
        
        stage('Deploy') {
            steps {
                // Export environment variables for docker-compose
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    bat "set DOCKER_USERNAME=%DOCKER_USERNAME%"
                    bat "set TAG=%TAG%"
                    bat "docker-compose -f %DOCKER_COMPOSE_FILE% down || echo 'No containers to stop'"
                    bat "docker-compose -f %DOCKER_COMPOSE_FILE% up -d"
                }
            }
        }
    }
    
    post {
        always {
            bat "docker logout"
            cleanWs()
        }
    }
}