pipeline {
    agent any
    environment {
        IMAGE_NAME = 'ghcr.io/KowMunGai/simpleApi'
    }

    stages {
        stage('Build') {
            agent {
                    label 'test'
            }

            steps {
                script {
                    sh 'docker kill $(docker ps -q) || true'
                    sh 'docker build -t api-image .'
                    sh 'docker tag api-image kowmungai/api-image:latest'
                }
            }
        }
        stage('Unit Test') {
            agent {
                    label 'test'
            }
            
            steps {
                sh 'docker run --rm api-image python -m unittest unit_test.py'
            }
        }
        stage('Deploy to Test') {
            agent {
                    label 'test'
            }
            
            steps {
                sh 'docker network create my_network || true'
                sh 'docker run -d --network my_network --name api-container -p 5000:5000 api-image'
            }
        }
        stage('Run Robot Tests') {
            agent {
                    label 'test'
            }
            
            steps {
                git branch: 'main', url: 'https://github.com/KowMunGai/robotTest.git'
                sh 'docker run --rm --network my_network -v /var/lib/jenkins/workspace/simpleApi:/tests api-image robot /tests/robotTest.robot'
            }
        }

        stage('Push image') {
            agent {
                    label 'test'
            }
            steps {
            //     withCredentials(
            //     [usernamePassword(
            //         credentialsId: 'tnt',
            //         passwordVariable: 'githubPassword',!!!!!!!!!!!!!!!
            //         usernameVariable: 'githubUser'
            //     )]
            // )
            {
                // sh "docker login ghcr.io -u ${githubUser} -p ${githubPassword}"
                sh "echo <your_token> | docker login ghcr.io -u KowMunGai -p-stdin"
                sh "docker pull ${IMAGE_NAME}"
                sh "docker tag ${IMAGE_NAME} ${IMAGE_NAME}:${env.BUILD_NUMBER}"
                sh "docker push ${IMAGE_NAME}:${env.BUILD_NUMBER}"
                sh "docker rmi ${IMAGE_NAME}:${env.BUILD_NUMBER}"
            }
            }
        }

        stage('Pull image') {
            agent {
                    label 'pre-prod'
            }
            steps {
                //     withCredentials(
                //     [usernamePassword(
                //         credentialsId: 'tnt',
                //         passwordVariable: 'githubPassword',
                //         usernameVariable: 'githubUser'
                //     )]
                // )
                {
                        sh "echo <your_token> | docker login ghcr.io -u KowMunGai -p-stdin"
                        sh "docker pull ${IMAGE_NAME}"
                }
            }
        }
        stage('runcontainer') {
            agent {
                    label 'pre-prod'
            }
            steps {
                    sh 'docker stop simple-api-container02'
                    sh 'docker rm simple-api-container02'
                    sh "docker run -d -p 8000:8000 --name simple-api-container02 ${IMAGE_NAME}"
            }
        }
        // stage('Deploy to Pre-Prod') {
        //     agent {
        //             label 'pre-prod'
        //     }
            
        //     steps {
        //         script {
        //             sh 'docker run -d -p 5001:5000 api-image'
        //         }
        //     }
        // }
    }

    post {
        always {
            sh 'docker stop api-container || true'
            sh 'docker rm api-container || true'
        }
    }
}
