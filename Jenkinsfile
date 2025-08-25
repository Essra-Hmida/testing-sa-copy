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
                checkout scm
            }
        }

        stage('Start Minikube & Set Docker Env') {
            steps {
                powershell '''
                    # Démarrer Minikube si ce n'est pas déjà fait
                    minikube status || minikube start

                    # Configurer Jenkins pour utiliser le Docker interne de Minikube
                    minikube -p minikube docker-env --shell powershell | Invoke-Expression

                    # Vérifier que Docker pointe bien vers Minikube
                    docker info
                '''
            }
        }

        stage('Build Angular') {
            steps {
                dir("${FRONTEND_PATH}") {
                    powershell '''
                        npm install
                        npm run build --prod
                        docker build -t $env:FRONTEND_IMAGE:$env:BUILD_NUMBER .
                    '''
                }
            }
        }

        stage('Build Spring Boot') {
            steps {
                dir("${BACKEND_PATH}") {
                    powershell '''
                        ./mvnw.cmd clean package -DskipTests
                        docker build -t $env:BACKEND_IMAGE:$env:BUILD_NUMBER .
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                powershell '''
                    # Mettre à jour les tags dans les manifests
                    (Get-Content spring-boot-server/k8s/deployment.yaml) -replace 'image: spring:.*', "image: spring:$env:BUILD_NUMBER" | Set-Content spring-boot-server/k8s/deployment.yaml
                    (Get-Content angular-16-client/k8s/deployment.yaml) -replace 'image: angular-app:.*', "image: angular-app:$env:BUILD_NUMBER" | Set-Content angular-16-client/k8s/deployment.yaml

                    # Appliquer les manifests
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
                powershell '''
                    kubectl get pods -o wide
                    kubectl get svc -o wide
                    kubectl get ingress
                '''
            }
        }
    }
}
