pipeline {
    agent any
    
    environment {
        DOCKER_USERNAME = credentials('docker-hub-credentials')
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
                    sh "docker build -t ${DOCKER_USERNAME}/spring-backend:${TAG} ."
                }
            }
        }
        
        stage('Build Frontend Image') {
            steps {
                dir('angular-16-client') {
                    sh "docker build -t ${DOCKER_USERNAME}/angular-frontend:${TAG} ."
                }
            }
        }
        
        stage('Push Images to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh "echo $PASSWORD | docker login -u $USERNAME --password-stdin"
                    sh "docker push ${DOCKER_USERNAME}/spring-backend:${TAG}"
                    sh "docker push ${DOCKER_USERNAME}/angular-frontend:${TAG}"
                    
                    // Also tag and push as latest
                    sh "docker tag ${DOCKER_USERNAME}/spring-backend:${TAG} ${DOCKER_USERNAME}/spring-backend:latest"
                    sh "docker tag ${DOCKER_USERNAME}/angular-frontend:${TAG} ${DOCKER_USERNAME}/angular-frontend:latest"
                    sh "docker push ${DOCKER_USERNAME}/spring-backend:latest"
                    sh "docker push ${DOCKER_USERNAME}/angular-frontend:latest"
                }
            }
        }
        
        stage('Deploy') {
            steps {
                // Export environment variables for docker-compose
                withEnv(["DOCKER_USERNAME=${DOCKER_USERNAME}", "TAG=${TAG}"]) {
                    sh "docker-compose -f ${DOCKER_COMPOSE_FILE} down || true"
                    sh "docker-compose -f ${DOCKER_COMPOSE_FILE} up -d"
                }
            }
        }
    }
    
    post {
        always {
            sh "docker logout"
            cleanWs()
        }
    }
}