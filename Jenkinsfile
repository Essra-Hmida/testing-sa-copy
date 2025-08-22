pipeline {
    agent any

    environment {
        // Replace with your actual Docker repo if pushing; else local Minikube
        SPRING_IMAGE = "spring:latest"
        ANGULAR_IMAGE = "angular-app:latest"
        KUBECONFIG     = "C:\\Users\\DELL\\.kube\\config"
        GIT_CREDENTIALS = credentials('github-credentials')
    }

    stages {
        stage('Checkout') {
            steps {
                git(
                    url: 'https://github.com/Essra-Hmida/testing-sa-copy.git',
                    credentialsId: 'github-credentials'
            }
        }

        stage('Setup Minikube Docker Env') {
            steps {
                // Switch Docker CLI to Minikube daemon
                bat 'minikube -p minikube docker-env --shell cmd > docker-env.cmd'
                bat 'docker-env.cmd'
            }
        }

        stage('Build Spring Boot') {
            steps {
                dir('spring-boot-server') {
                    bat 'mvn clean package -DskipTests'
                    bat 'docker build -t %SPRING_IMAGE% .'
                }
            }
        }

        stage('Build Angular App') {
            steps {
                dir('angular-16-client') {
                    bat 'npm install'
                    bat 'npm run build --prod'
                    bat 'docker build -t %ANGULAR_IMAGE% .'
                }
            }
        }

        stage('Deploy Kubernetes Manifests') {
            steps {
                // Apply manifests folder by folder
                bat 'kubectl apply -f mysql/k8s/'
                bat 'kubectl apply -f phpmyadmin/k8s/'
                bat 'kubectl apply -f spring-boot-server/k8s/'
                bat 'kubectl apply -f angular-16-client/k8s/'
                bat 'kubectl apply -f ingress/k8s/'
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully!'
        }
        failure {
            echo '🚨 Pipeline failed. Check logs!'
        }
    }
}
