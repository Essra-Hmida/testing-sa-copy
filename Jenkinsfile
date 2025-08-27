pipeline {
    agent any

    environment {
        FRONTEND_IMAGE = "angular-app:latest"
        BACKEND_IMAGE = "springboot-app:latest"
        KUBECONFIG = "/home/jenkins/.kube/minikube/config"
    }

    stages {

        stage('Checkout SCM') {
            steps {
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/master']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/Essra-Hmida/testing-sa-copy.git',
                        credentialsId: 'github-creds'
                    ]]
                ])
            }
        }

        stage('Build Angular') {
            steps {
                dir('angular-16-client') {
                    sh 'npm install'
                    sh 'npm run build --prod'
                }
            }
        }

        stage('Build Spring Boot') {
            steps {
                dir('spring-boot-server') {
                    sh 'mvn clean package -DskipTests'
                }
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    // Utiliser Docker de Minikube
                    sh 'eval $(minikube -p minikube docker-env)'
                    
                    sh "docker build -t ${env.FRONTEND_IMAGE} angular-16-client"
                    sh "docker build -t ${env.BACKEND_IMAGE} spring-boot-server"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Déploiement avec kubeconfig monté
                    sh "kubectl --kubeconfig=${env.KUBECONFIG} apply -f k8s/angular-16-client/ --validate=false"
                    sh "kubectl --kubeconfig=${env.KUBECONFIG} apply -f k8s/spring-boot-server/ --validate=false"
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    sh "kubectl --kubeconfig=${env.KUBECONFIG} get pods"
                    sh "kubectl --kubeconfig=${env.KUBECONFIG} get svc"
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline terminé avec succès !'
        }
        failure {
            echo 'Pipeline échoué. Vérifie les logs.'
        }
    }
}
