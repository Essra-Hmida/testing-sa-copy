pipeline {
    agent any

    environment {
        FRONTEND_IMAGE = 'angular-16-client:latest'
        BACKEND_IMAGE  = 'spring-boot-server:latest'
        KUBECONFIG     = '/home/jenkins/.kube/config'  // point vers kubeconfig monté
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/Essra-Hmida/testing-sa-copy.git', credentialsId: 'github-creds'
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
                sh "kubectl --kubeconfig=${KUBECONFIG} apply -f mysql/k8s/ --validate=false"
                sh "kubectl --kubeconfig=${KUBECONFIG} apply -f phpmyadmin/k8s/ --validate=false"
                sh "kubectl --kubeconfig=${KUBECONFIG} apply -f spring-boot-server/k8s/ --validate=false"
                sh "kubectl --kubeconfig=${KUBECONFIG} apply -f angular-16-client/k8s/ --validate=false"
                sh "kubectl --kubeconfig=${KUBECONFIG} apply -f ingress/k8s/ --validate=false"
            }
        }

        stage('Verify Deployment') {
            steps {
                sh "kubectl --kubeconfig=${KUBECONFIG} get pods -o wide"
                sh "kubectl --kubeconfig=${KUBECONFIG} get svc"
                sh "kubectl --kubeconfig=${KUBECONFIG} get ingress"
            }
        }
    }
}
