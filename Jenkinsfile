pipeline {
    agent any

    environment {
        FRONTEND_IMAGE = "angular-app"
        BACKEND_IMAGE  = "spring"
        FRONTEND_PATH  = "angular-16-client"
        BACKEND_PATH   = "spring-boot-server"
        KUBECONFIG     = "C:\\Users\\DELL\\.kube\\config"
    }

    stages {
        stage('Checkout SCM') {
            steps {
                echo "📥 Clonage du repo Git"
                checkout scm
            }
        }

        stage('Build Angular') {
            steps {
                dir("${FRONTEND_PATH}") {
                    echo "⚡ Build Angular + Docker image"
                    bat '''
@echo off
REM Configure le shell pour utiliser le Docker de Minikube
@FOR /f "tokens=*" %i IN ('minikube docker-env --shell cmd') DO @%i

REM Installer les dépendances et builder Angular
npm install
npm run build --prod

REM Construire l'image Docker directement dans Minikube
docker build -t %FRONTEND_IMAGE%:latest .
'''
                }
            }
        }

        stage('Build Spring Boot') {
            steps {
                dir("${BACKEND_PATH}") {
                    echo "⚡ Build Spring Boot + Docker image"
                    bat '''
@echo off
REM Configure le shell pour utiliser le Docker de Minikube
@FOR /f "tokens=*" %i IN ('minikube docker-env --shell cmd') DO @%i

REM Builder le projet Spring Boot
mvnw.cmd clean package -DskipTests

REM Construire l'image Docker directement dans Minikube
docker build -t %BACKEND_IMAGE%:latest .
'''
                }
            }
        }

        stage('Deploy Kubernetes Resources') {
            steps {
                echo "🚀 Déploiement des manifests K8s"
                bat '''
kubectl apply -f mysql/k8s/ --validate=false
kubectl apply -f phpmyadmin/k8s/ --validate=false
kubectl apply -f spring-boot-server/k8s/ --validate=false
kubectl apply -f angular-16-client/k8s/ --validate=false
kubectl apply -f ingress/k8s/ --validate=false
'''
            }
        }

        stage('Verify Deployment') {
            steps {
                echo "🔍 Vérification des pods et services"
                bat '''
kubectl get pods -o wide
kubectl get svc -o wide
kubectl get ingress
'''
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline terminé avec succès"
        }
        failure {
            echo "❌ Échec du pipeline → rollback"
            bat '''
kubectl rollout undo deployment spring-deployment 2>nul || echo "Spring rollback failed"
kubectl rollout undo deployment angular-deployment 2>nul || echo "Angular rollback failed"
'''
        }
    }
}
