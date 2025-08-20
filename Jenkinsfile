pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo "📥 Clonage du repo Git"
                checkout([$class: 'GitSCM',
                    branches: [[name: "*/master"]],
                    userRemoteConfigs: [[
                        url: 'https://github.com/Essra-Hmida/testing-sa-copy.git',
                        credentialsId: 'github-credentials'
                    ]]
                ])
            }
        }

        stage('Setup Minikube Docker Env') {
            steps {
                echo "⚙️ Configuration Docker Minikube"
                bat """
                    minikube docker-env --shell cmd > minikube_env.bat
                    call minikube_env.bat
                """
            }
        }

        stage('Check Docker Env') {
            steps {
                echo "🔍 Vérification Docker Minikube"
                bat "docker ps"
            }
        }

        stage('Build Angular') {
            steps {
                echo "🛠️ Build Angular"
                bat """
                    cd angular-16-client
                    npm install
                    npm run build --prod
                    docker build -t angular-app:latest .
                """
            }
        }

        stage('Build Spring Boot') {
            steps {
                echo "☕ Build Spring Boot"
                bat """
                    cd spring-boot-server
                    mvn clean package -DskipTests
                    docker build -t spring-app:latest .
                """
            }
        }

        stage('Deploy Kubernetes Resources') {
            steps {
                echo "🚀 Déploiement sur Kubernetes"
                bat """
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
                echo "🔎 Vérification des pods et services"
                bat "kubectl get pods -o wide"
                bat "kubectl get svc -o wide"
                bat "kubectl get ingress"
            }
        }
    }

    post {
        failure {
            echo "❌ Échec du pipeline → rollback"
            script {
                bat '''
                    kubectl rollout undo deployment spring-deployment   2>nul  || echo "Spring rollback failed"
                    kubectl rollout undo deployment angular-deployment 2>nul  || echo "Angular rollback failed"
                '''
            }
        }
        success {
            echo "✅ Pipeline terminé avec succès"
        }
    }
}
