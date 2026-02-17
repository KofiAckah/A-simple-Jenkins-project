pipeline {
    agent any
    
    environment {
        // AWS Configuration
        AWS_REGION = 'eu-west-1'
        AWS_ACCOUNT_ID = credentials('aws-account-id')
        ECR_REPO_NAME = 'jenkins-cicd-app'
        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        ECR_REPO_URL = "${ECR_REGISTRY}/${ECR_REPO_NAME}"
        
        // Image versioning
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '=== Checking out code from GitHub ==='
                checkout scm
            }
        }
        
        stage('Get App Server IP from Terraform Output') {
            steps {
                script {
                    echo '=== Fetching App Server Private IP from AWS ==='
                    
                    // Query AWS for PRIVATE IP (same VPC communication)
                    def appServerPrivateIp = sh(
                        script: """
                            aws ec2 describe-instances \
                              --region ${AWS_REGION} \
                              --filters "Name=tag:Name,Values=jenkins-cicd-dev-app-server" \
                                        "Name=instance-state-name,Values=running" \
                              --query 'Reservations[0].Instances[0].PrivateIpAddress' \
                              --output text
                        """,
                        returnStdout: true
                    ).trim()
                    
                    def appServerPublicIp = sh(
                        script: """
                            aws ec2 describe-instances \
                              --region ${AWS_REGION} \
                              --filters "Name=tag:Name,Values=jenkins-cicd-dev-app-server" \
                                        "Name=instance-state-name,Values=running" \
                              --query 'Reservations[0].Instances[0].PublicIpAddress' \
                              --output text
                        """,
                        returnStdout: true
                    ).trim()
                    
                    if (appServerPrivateIp && appServerPrivateIp != 'None') {
                        env.APP_SERVER_PRIVATE_IP = appServerPrivateIp
                        env.APP_SERVER_PUBLIC_IP = appServerPublicIp
                        echo "Found App Server Private IP: ${env.APP_SERVER_PRIVATE_IP}"
                        echo "Found App Server Public IP: ${env.APP_SERVER_PUBLIC_IP}"
                    } else {
                        error "Unable to find App Server. Please ensure the app server is running."
                    }
                }
            }
        }
        
        stage('Install Dependencies') {
            steps {
                echo '=== Installing Node.js dependencies ==='
                dir('app') {
                    sh 'npm install'
                }
            }
        }
        
        stage('Run Tests') {
            steps {
                echo '=== Running unit tests ==='
                dir('app') {
                    sh 'npm test'
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo '=== Building Docker image ==='
                dir('app') {
                    script {
                        sh """
                            docker build -t ${ECR_REPO_URL}:${IMAGE_TAG} .
                            docker tag ${ECR_REPO_URL}:${IMAGE_TAG} ${ECR_REPO_URL}:latest
                        """
                    }
                }
            }
        }
        
        stage('Push to ECR') {
            steps {
                echo '=== Authenticating with AWS ECR and pushing image ==='
                script {
                    sh """
                        aws ecr get-login-password --region ${AWS_REGION} | \
                        docker login --username AWS --password-stdin ${ECR_REGISTRY}
                        
                        docker push ${ECR_REPO_URL}:${IMAGE_TAG}
                        docker push ${ECR_REPO_URL}:latest
                    """
                }
            }
        }
        
        stage('Deploy to App Server') {
            steps {
                echo "=== Deploying application to App Server (Private: ${env.APP_SERVER_PRIVATE_IP}, Public: ${env.APP_SERVER_PUBLIC_IP}) ==="
                script {
                    sshagent(['ec2-ssh-key']) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ec2-user@${env.APP_SERVER_PRIVATE_IP} << 'ENDSSH'
                            
                            # Login to ECR from app server
                            aws ecr get-login-password --region ${AWS_REGION} | \
                            docker login --username AWS --password-stdin ${ECR_REGISTRY}
                            
                            # Pull the latest image
                            docker pull ${ECR_REPO_URL}:latest
                            
                            # Stop and remove existing container if it exists
                            docker stop nodeapp 2>/dev/null || true
                            docker rm nodeapp 2>/dev/null || true
                            
                            # Run the new container
                            docker run -d \
                              --name nodeapp \
                              --restart unless-stopped \
                              -p 3000:3000 \
                              ${ECR_REPO_URL}:latest
                            
                            # Verify the container is running
                            docker ps | grep nodeapp
                            
                            # Wait and test the application
                            sleep 5
                            curl -f http://localhost:3000 || exit 1
                            
ENDSSH
                        """
                    }
                }
            }
        }
        
        stage('Cleanup Docker Images') {
            steps {
                echo '=== Cleaning up old Docker images on Jenkins server ==='
                script {
                    sh """
                        docker images ${ECR_REPO_URL} --format "{{.Tag}}" | \
                        grep -E '^[0-9]+\$' | \
                        sort -rn | \
                        tail -n +4 | \
                        xargs -r -I {} docker rmi ${ECR_REPO_URL}:{} || true
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo '✅ Pipeline completed successfully!'
            echo "Application deployed and accessible at: http://${env.APP_SERVER_PUBLIC_IP}:3000"
        }
        
        failure {
            echo '❌ Pipeline failed! Check the logs above for details.'
        }
        
        always {
            echo '=== Cleaning up workspace ==='
            sh 'docker system prune -f || true'
        }
    }
}
