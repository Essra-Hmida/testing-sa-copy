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

        stage('Set Docker Env for Minikube') {
            steps {
                echo "🔧 Configure Jenkins to use Minikube Docker"
                bat '''
                    REM Generate env variables into a batch file
                    minikube docker-env --shell cmd > docker_env.bat
                    call docker_env.bat
                    docker info
                '''
            }
        }

        stage('Build Angular') {
            steps {
                dir("${FRONTEND_PATH}") {
                    bat '''
                        npm install
                        npm run build --prod
                        call ..\\docker_env.bat
                        docker build -t %FRONTEND_IMAGE%:%BUILD_NUMBER% .
                    '''
                }
            }
        }

        stage('Build Spring Boot') {
            steps {
                dir("${BACKEND_PATH}") {
                    bat '''
                        mvnw.cmd clean package -DskipTests
                        call ..\\docker_env.bat
                        docker build -t %BACKEND_IMAGE%:%BUILD_NUMBER% .
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                bat '''
                    REM Update image tags in Kubernetes manifests before applying
                    powershell -Command "(Get-Content spring-boot-server/k8s/deployment.yaml) -replace 'image: spring:.*', 'image: spring:%BUILD_NUMBER%' | Set-Content spring-boot-server/k8s/deployment.yaml"
                    powershell -Command "(Get-Content angular-16-client/k8s/deployment.yaml) -replace 'image: angular-app:.*', 'image: angular-app:%BUILD_NUMBER%' | Set-Content angular-16-client/k8s/deployment.yaml"

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
                bat '''
                    kubectl get pods -o wide
                    kubectl get svc -o wide
                    kubectl get ingress
                '''
            }
        }
    }
}
