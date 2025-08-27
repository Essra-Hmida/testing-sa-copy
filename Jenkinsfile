pipeline {
    agent any

    environment {
        FRONTEND_IMAGE = 'angular-16-client:latest'
        BACKEND_IMAGE  = 'spring-boot-server:latest'
        MINIKUBE_PROFILE = 'minikube'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/Essra-Hmida/testing-sa-copy.git', credentialsId: 'github-creds'
            }
        }

        stage('Configure Minikube Docker') {
            steps {
                echo "⚡ Configuring Docker to use Minikube daemon"
                sh """
                mkdir -p \$HOME/.minikube
                minikube -p ${MINIKUBE_PROFILE} docker-env --shell bash > \$HOME/.minikube/docker-env.sh
                source \$HOME/.minikube/docker-env.sh
                """
            }
        }

        stage('Build Angular') {
            steps {
                dir('angular-16-client') {
                    sh 'npm install'
                    sh 'npm run build -- --output-path=dist'
                    sh "docker build -t ${FRONTEND_IMAGE} ."
                }
            }
        }

        stage('Build Spring Boot') {
            steps {
                dir('spring-boot-server') {
                    sh './mvnw clean package -DskipTests'
                    sh "docker build -t ${BACKEND_IMAGE} ."
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo "🚀 Deploying to Minikube cluster"
                sh 'kubectl apply -f mysql/k8s/ --validate=false'
                sh 'kubectl apply -f phpmyadmin/k8s/ --validate=false'
                sh 'kubectl apply -f spring-boot-server/k8s/ --validate=false'
                sh 'kubectl apply -f angular-16-client/k8s/ --validate=false'
                sh 'kubectl apply -f ingress/k8s/ --validate=false'
            }
        }

        stage('Verify Deployment') {
            steps {
                sh 'kubectl get pods -o wide'
                sh 'kubectl get svc'
                sh 'kubectl get ingress'
            }
        }
    }
}
