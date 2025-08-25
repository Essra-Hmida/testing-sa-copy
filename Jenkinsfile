pipeline {
    agent any

    environment {
        FRONTEND_IMAGE = "angular-app"
        BACKEND_IMAGE  = "spring"
        FRONTEND_PATH  = "/home/docker/angular-16-client"
        BACKEND_PATH   = "/home/docker/spring-boot-server"
        KUBECONFIG     = "C:\\Users\\DELL\\.kube\\config"
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Copy Project to Minikube') {
            steps {
                powershell '''
                    # Créer un dossier temporaire dans Minikube
                    minikube ssh "mkdir -p /home/docker"

                    # Copier le projet Angular
                    minikube cp angular-16-client /home/docker/angular-16-client

                    # Copier le projet Spring Boot
                    minikube cp spring-boot-server /home/docker/spring-boot-server
                '''
            }
        }

        stage('Build Angular in Minikube') {
            steps {
                powershell '''
                    minikube ssh "cd ${FRONTEND_PATH} && npm install && npm run build --prod && docker build -t angular-app:$env:BUILD_NUMBER ."
                '''
            }
        }

        stage('Build Spring Boot in Minikube') {
            steps {
                powershell '''
                    minikube ssh "cd ${BACKEND_PATH} && ./mvnw clean package -DskipTests && docker build -t spring:$env:BUILD_NUMBER ."
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                powershell '''
                    # Mettre à jour les images directement dans les deployments
                    kubectl set image deployment/spring-deployment spring=spring:$env:BUILD_NUMBER --kubeconfig $env:KUBECONFIG
                    kubectl set image deployment/angular-deployment angular-app=angular-app:$env:BUILD_NUMBER --kubeconfig $env:KUBECONFIG

                    # Appliquer les autres manifests (MySQL, phpMyAdmin, ingress)
                    kubectl apply -f mysql/k8s/ --validate=false --kubeconfig $env:KUBECONFIG
                    kubectl apply -f phpmyadmin/k8s/ --validate=false --kubeconfig $env:KUBECONFIG
                    kubectl apply -f ingress/k8s/ --validate=false --kubeconfig $env:KUBECONFIG
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                powershell '''
                    kubectl get pods -o wide --kubeconfig $env:KUBECONFIG
                    kubectl get svc -o wide --kubeconfig $env:KUBECONFIG
                    kubectl get ingress --kubeconfig $env:KUBECONFIG
                '''
            }
        }
    }
}
