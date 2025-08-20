pipeline {
    agent any

    triggers {
        // Déclenche le build lors d'un push sur master
        githubPush()
        
        // Alternative: polling SCM toutes les 5 minutes
        // pollSCM('H/5 * * * *')
    }

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
                script {
                    if (isUnix()) {
                        sh "eval \$(minikube docker-env)"
                    } else {
                        bat """
                            @echo off
                            for /f "tokens=*" %%i in ('minikube docker-env') do %%i
                        """
                    }
                }
            }
        }

        stage('Build Angular') {
            steps {
                dir("${FRONTEND_PATH}") {
                    echo "⚡ Build Angular + Docker image"
                    script {
                        if (isUnix()) {
                            sh "npm install"
                            sh "npm run build --prod"
                            sh "docker build -t ${FRONTEND_IMAGE}:latest ."
                        } else {
                            bat "npm install"
                            bat "npm run build --prod"
                            bat "docker build -t ${FRONTEND_IMAGE}:latest ."
                        }
                    }
                }
            }
        }

        stage('Build Spring Boot') {
            steps {
                dir("${BACKEND_PATH}") {
                    echo "⚡ Build Spring Boot + Docker image"
                    script {
                        if (isUnix()) {
                            sh "./mvnw clean package -DskipTests"
                            sh "docker build -t ${BACKEND_IMAGE}:latest ."
                        } else {
                            bat "mvnw.cmd clean package -DskipTests"
                            bat "docker build -t ${BACKEND_IMAGE}:latest ."
                        }
                    }
                }
            }
        }

        stage('Deploy Kubernetes Resources') {
            steps {
                echo "🚀 Déploiement des manifests K8s"
                script {
                    if (isUnix()) {
                        sh """
                            kubectl apply -f mysql/k8s/
                            kubectl apply -f phpmyadmin/k8s/
                            kubectl apply -f spring-boot-server/k8s/
                            kubectl apply -f angular-16-client/k8s/
                            kubectl apply -f ingress/k8s/
                        """
                    } else {
                        bat """
                            kubectl apply -f mysql/k8s/
                            kubectl apply -f phpmyadmin/k8s/
                            kubectl apply -f spring-boot-server/k8s/
                            kubectl apply -f angular-16-client/k8s/
                            kubectl apply -f ingress/k8s/
                        """
                    }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                echo "🔍 Vérification des pods et services"
                script {
                    if (isUnix()) {
                        sh "kubectl get pods -o wide"
                        sh "kubectl get svc -o wide"
                        sh "kubectl get ingress"
                    } else {
                        bat "kubectl get pods -o wide"
                        bat "kubectl get svc -o wide"
                        bat "kubectl get ingress"
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline terminé avec succès"
        }
        failure {
            echo "❌ Échec du pipeline → rollback"
            script {
                try {
                    if (isUnix()) {
                        sh "kubectl rollout undo deployment spring-deployment || true"
                        sh "kubectl rollout undo deployment angular-deployment || true"
                    } else {
                        bat """
                            kubectl rollout undo deployment spring-deployment 2>nul || echo "Spring rollback failed"
                            kubectl rollout undo deployment angular-deployment 2>nul || echo "Angular rollback failed"
                        """
                    }
                } catch (Exception e) {
                    echo "Erreur lors du rollback: ${e.getMessage()}"
                }
            }
        }
    }
}