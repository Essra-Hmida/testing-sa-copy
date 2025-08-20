pipeline {
    agent any

    environment {
        FRONTEND_IMAGE = "angular-app"
        BACKEND_IMAGE  = "spring"

        FRONTEND_PATH  = "angular-16-client"
        BACKEND_PATH   = "spring-boot-server"
    }

    stages {
        stage('Checkout') {
            steps {
                echo "📥 Clonage du repo Git"
                checkout scm
            }
        }

        stage('Setup Minikube Docker Env') {
            steps {
                echo "⚙️ Configuration Docker Minikube"
                sh "eval \$(minikube docker-env)"
            }
        }

        stage('Build Angular') {
            steps {
                dir("${FRONTEND_PATH}") {
                    echo "⚡ Build Angular + Docker image"
                    sh "npm install"
                    sh "npm run build --prod"
                    sh "docker build -t ${FRONTEND_IMAGE}:latest ."
                }
            }
        }

        stage('Build Spring Boot') {
            steps {
                dir("${BACKEND_PATH}") {
                    echo "⚡ Build Spring Boot + Docker image"
                    sh "./mvnw clean package -DskipTests"
                    sh "docker build -t ${BACKEND_IMAGE}:latest ."
                }
            }
        }

        stage('Deploy Kubernetes Resources') {
            steps {
                echo "🚀 Déploiement des manifests K8s"
                sh """
                    kubectl apply -f mysql/k8s/
                    kubectl apply -f phpmyadmin/k8s/
                    kubectl apply -f spring-boot-server/k8s/
                    kubectl apply -f angular-16-client/k8s/
                    kubectl apply -f ingress/k8s/
                """
            }
        }

        stage('Verify Deployment') {
            steps {
                echo "🔍 Vérification des pods et services"
                sh "kubectl get pods -o wide"
                sh "kubectl get svc -o wide"
                sh "kubectl get ingress"
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline terminé avec succès"
        }
        failure {
            echo "❌ Échec du pipeline → rollback"
            sh "kubectl rollout undo deployment spring-deployment || true"
            sh "kubectl rollout undo deployment angular-deployment || true"
        }
    }
}
