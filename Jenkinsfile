pipeline {
    agent {
        kubernetes {
            yamlFile 'jenkins-agent.yaml'
            defaultContainer 'jnlp'
        }
    }

    environment {
        DOCKER_REGISTRY = credentials('docker-registry')
        GIT_REPO = 'https://github.com/your-org/devops-reference-project.git'
        APP_NAME = 'sample-app'
        IMAGE_TAG = "${env.BUILD_NUMBER}-${env.GIT_COMMIT_SHORT}"
        FULL_IMAGE_NAME = "${DOCKER_REGISTRY_USR}/${APP_NAME}:${IMAGE_TAG}"
        BRANCH_NAME = "${env.GIT_BRANCH}"
        TRIVY_CACHE_DIR = '/tmp/trivy-cache'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.GIT_COMMIT_SHORT = sh(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()
                }
            }
        }

        stage('Setup Environment') {
            steps {
                container('builder') {
                    script {
                        // Create necessary directories
                        sh 'mkdir -p ${TRIVY_CACHE_DIR}'
                        
                        // Setup Node.js
                        sh 'node --version && npm --version'
                        
                        // Setup Docker
                        sh 'docker version'
                    }
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                container('builder') {
                    dir('apps/sample-app') {
                        sh 'npm ci --silent'
                    }
                }
            }
        }

        stage('Code Quality Checks') {
            parallel {
                stage('Lint') {
                    steps {
                        container('builder') {
                            dir('apps/sample-app') {
                                sh 'npm run lint'
                            }
                        }
                    }
                }
                
                stage('Unit Tests') {
                    steps {
                        container('builder') {
                            dir('apps/sample-app') {
                                sh 'npm test -- --coverage'
                                sh 'npm run test:ci'
                            }
                        }
                    }
                    post {
                        always {
                            // Publish test results if available
                            script {
                                if (fileExists('apps/sample-app/coverage/lcov.info')) {
                                    publishHTML([
                                        allowMissing: false,
                                        alwaysLinkToLastBuild: true,
                                        keepAll: true,
                                        reportDir: 'apps/sample-app/coverage',
                                        reportFiles: 'lcov-report/index.html',
                                        reportName: 'Code Coverage Report'
                                    ])
                                }
                            }
                        }
                    }
                }
            }
        }

        stage('Security Scans') {
            parallel {
                stage('SAST - Trivy FS') {
                    steps {
                        container('scanner') {
                            script {
                                // Scan source code for vulnerabilities
                                sh '''
                                    trivy fs \
                                        --format sarif \
                                        --output trivy-fs-results.sarif \
                                        --exit-code 1 \
                                        --severity HIGH,CRITICAL \
                                        .
                                '''
                            }
                        }
                    }
                    post {
                        always {
                            archiveArtifacts artifacts: 'trivy-fs-results.sarif', fingerprint: true
                        }
                    }
                }

                stage('IaC Security Scan') {
                    steps {
                        container('scanner') {
                            script {
                                // Scan Terraform files
                                sh '''
                                    trivy config \
                                        --format sarif \
                                        --output trivy-iac-results.sarif \
                                        --exit-code 1 \
                                        --severity HIGH,CRITICAL \
                                        terraform/
                                '''
                                
                                // Scan Kubernetes manifests
                                sh '''
                                    trivy config \
                                        --format sarif \
                                        --output trivy-k8s-results.sarif \
                                        --exit-code 1 \
                                        --severity HIGH,CRITICAL \
                                        manifests/
                                '''
                            }
                        }
                    }
                    post {
                        always {
                            archiveArtifacts artifacts: 'trivy-*-results.sarif', fingerprint: true
                        }
                    }
                }
            }
        }

        stage('Build Application') {
            steps {
                container('builder') {
                    dir('apps/sample-app') {
                        sh 'npm run build'
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                container('builder') {
                    script {
                        // Build Docker image
                        sh """
                            docker build \
                                -t ${FULL_IMAGE_NAME} \
                                --build-arg BUILD_NUMBER=${BUILD_NUMBER} \
                                --build-arg GIT_COMMIT=${GIT_COMMIT_SHORT} \
                                apps/sample-app/
                        """
                        
                        // Tag for deployment
                        if (env.BRANCH_NAME == 'main') {
                            sh "docker tag ${FULL_IMAGE_NAME} ${DOCKER_REGISTRY_USR}/${APP_NAME}:latest"
                        } else if (env.BRANCH_NAME == 'develop') {
                            sh "docker tag ${FULL_IMAGE_NAME} ${DOCKER_REGISTRY_USR}/${APP_NAME}:staging"
                        }
                    }
                }
            }
        }

        stage('Container Security Scan') {
            steps {
                container('scanner') {
                    script {
                        // Scan the built container
                        sh """
                            trivy image \
                                --format sarif \
                                --output trivy-container-results.sarif \
                                --exit-code 1 \
                                --severity HIGH,CRITICAL \
                                ${FULL_IMAGE_NAME}
                        """
                    }
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'trivy-container-results.sarif', fingerprint: true
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                container('builder') {
                    script {
                        // Login to registry
                        sh 'echo ${DOCKER_REGISTRY_PSW} | docker login ${DOCKER_REGISTRY_USR} -u ${DOCKER_REGISTRY_USR} --password-stdin'
                        
                        // Push images
                        sh "docker push ${FULL_IMAGE_NAME}"
                        
                        if (env.BRANCH_NAME == 'main') {
                            sh "docker push ${DOCKER_REGISTRY_USR}/${APP_NAME}:latest"
                        } else if (env.BRANCH_NAME == 'develop') {
                            sh "docker push ${DOCKER_REGISTRY_USR}/${APP_NAME}:staging"
                        }
                    }
                }
            }
        }

        stage('Update GitOps Manifests') {
            steps {
                container('builder') {
                    script {
                        // Configure git
                        sh """
                            git config --global user.name 'Jenkins CI'
                            git config --global user.email 'jenkins@company.com'
                        """

                        // Determine target branch
                        def targetBranch = env.BRANCH_NAME == 'main' ? 'main' : 'develop'
                        
                        // Create/update deployment branch for GitOps
                        sh """
                            git checkout ${targetBranch} || git checkout -b ${targetBranch} origin/${targetBranch}
                        """

                        // Update deployment manifests with new image
                        sh """
                            sed -i "s|image: sample-app:latest|image: ${FULL_IMAGE_NAME}|g" apps/sample-app/k8s/deployment.yaml
                            sed -i "s|image: .*:staging|image: ${FULL_IMAGE_NAME}|g" apps/sample-app/k8s/deployment.yaml
                        """

                        // Commit and push changes
                        sh """
                            git add apps/sample-app/k8s/deployment.yaml
                            if ! git diff --cached --quiet; then
                                git commit -m "ci: Update image to ${IMAGE_TAG} [skip ci]"
                                git push origin ${targetBranch}
                            else
                                echo "No changes to commit"
                            fi
                        """

                        // Trigger Argo CD sync (if argocd CLI is available)
                        try {
                            sh """
                                argocd app sync sample-app --revision ${targetBranch}
                                argocd app wait sample-app --health --timeout 300
                            """
                        } catch (Exception e) {
                            echo "Argo CD sync failed: ${e.getMessage()}"
                            echo "Manual sync may be required"
                        }
                    }
                }
            }
        }

        stage('Deploy to Staging') {
            when {
                branch 'develop'
            }
            steps {
                script {
                    echo "Deploying to staging environment..."
                    echo "Argo CD will automatically deploy from develop branch"
                    
                    // Optional: Wait for deployment to complete
                    try {
                        sh """
                            sleep 30
                            argocd app get sample-app
                        """
                    } catch (Exception e) {
                        echo "Could not verify staging deployment: ${e.getMessage()}"
                    }
                }
            }
        }

        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to Production?', ok: 'Deploy'
                script {
                    echo "Deploying to production environment..."
                    echo "Argo CD will automatically deploy from main branch"
                    
                    // Optional: Wait for deployment to complete
                    try {
                        sh """
                            sleep 30
                            argocd app get sample-app
                        """
                    } catch (Exception e) {
                        echo "Could not verify production deployment: ${e.getMessage()}"
                    }
                }
            }
        }
    }

    post {
        always {
            // Clean up workspace
            cleanWs()
        }
        
        success {
            script {
                if (env.BRANCH_NAME in ['main', 'develop']) {
                    slackSend(
                        channel: '#devops',
                        color: 'good',
                        message: "✅ Jenkins build ${env.JOB_NAME} #${env.BUILD_NUMBER} succeeded\nBranch: ${env.BRANCH_NAME}\nCommit: ${env.GIT_COMMIT_SHORT}"
                    )
                }
            }
        }
        
        failure {
            script {
                slackSend(
                    channel: '#devops',
                    color: 'danger',
                    message: "❌ Jenkins build ${env.JOB_NAME} #${env.BUILD_NUMBER} failed\nBranch: ${env.BRANCH_NAME}\nCommit: ${env.GIT_COMMIT_SHORT}"
                )
            }
        }
        
        unstable {
            script {
                slackSend(
                    channel: '#devops',
                    color: 'warning',
                    message: "⚠️ Jenkins build ${env.JOB_NAME} #${env.BUILD_NUMBER} unstable\nBranch: ${env.BRANCH_NAME}\nCommit: ${env.GIT_COMMIT_SHORT}"
                )
            }
        }
    }
}