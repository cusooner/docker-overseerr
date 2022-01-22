pipeline {
    environment {
        registry = "thebungler/overseerr"
        registryCredential = 'dockerhub_id'
        dockerImage = ''
    }
    agent any
    stages {
        stage('Cloning our git') {
            steps {
                git 'https://github.com/thebungler/docker-overseerr.git'
            }
        }
        stage ('Building our image') {
            steps {
                script {
                    dockerImage = docker.build registry + ":$BUILD_NUMBER"
                }
            }
        }
        stage ('Deploy image') {
            steps {
                script {
                    docker.withRegistry('', registryCredential) {
                        dockerImage.push()
                    }
                }
            }
        }
        stage ('Cleanup') {
            steps {
                sh "docker rmi $registry:$BUILD_NUMBER"
            }
        }
    }
}