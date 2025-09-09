pipeline {
    agent any

    environment {
        KUBECONFIG = '/home/jenkins/.kube/config'
        DOCKER_IMAGE_SPRING = "spring-boot-app:${BUILD_NUMBER}"
        DOCKER_IMAGE_ANGULAR = "angular-app:${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                git(
                    branch: 'master',
                    credentialsId: 'github-creds',
                    url: 'https://github.com/Essra-Hmida/testing-sa-copy.git'
                )
            }
        }

        stage('Build Spring Boot') {
            steps {
                dir('spring-boot-server') {
                    sh 'mvn clean package -DskipTests'
                    sh "docker build -t ${DOCKER_IMAGE_SPRING} ."
                }
            }
        }

        stage('Build Angular') {
            steps {
                dir('angular-16-client') {
                    sh "docker build --no-cache -t ${DOCKER_IMAGE_ANGULAR} ."
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh """
                    sed -i 's|image: spring-boot-app:.*|image: ${DOCKER_IMAGE_SPRING}|g' spring-boot-server/k8s/spring-deployment.yaml
                    sed -i 's|image: angular-app:.*|image: ${DOCKER_IMAGE_ANGULAR}|g' angular-16-client/k8s/angular-deploy.yaml

                    kubectl apply -f mysql/k8s/ --validate=false
                    kubectl apply -f phpmyadmin/k8s/ --validate=false
                    kubectl apply -f spring-boot-server/k8s/ --validate=false
                    kubectl apply -f angular-16-client/k8s/ --validate=false
                    kubectl apply -f ingress/k8s/ --validate=false
                    """
                }
            }
        }
    }
}
