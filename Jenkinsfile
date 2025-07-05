pipeline {
    agent any
    
    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
        AWS_CREDENTIALS = credentials('aws-credentials-id') // Configure this in Jenkins
        TF_VAR_environment = 'dev'
        TF_IN_AUTOMATION = 'true'
        TF_CLI_ARGS = '-no-color'
    }
    
    parameters {
        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Select Terraform action to perform'
        )
        booleanParam(
            name: 'AUTO_APPROVE',
            defaultValue: false,
            description: 'Auto approve terraform apply/destroy (use with caution)'
        )
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo "Checked out code from repository"
            }
        }
        
        stage('Setup Terraform') {
            steps {
                script {
                    // Install Terraform if not already available
                    sh '''
                        if ! command -v terraform &> /dev/null; then
                            echo "Installing Terraform..."
                            wget -q https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
                            unzip terraform_1.6.6_linux_amd64.zip
                            sudo mv terraform /usr/local/bin/
                            rm terraform_1.6.6_linux_amd64.zip
                        fi
                        terraform version
                    '''
                }
            }
        }
        
        stage('Terraform Init') {
            steps {
                dir('aws-vpc') {
                    script {
                        sh '''
                            echo "Initializing Terraform..."
                            terraform init -upgrade
                        '''
                    }
                }
            }
        }
        
        stage('Terraform Validate') {
            steps {
                dir('aws-vpc') {
                    script {
                        sh '''
                            echo "Validating Terraform configuration..."
                            terraform validate
                        '''
                    }
                }
            }
        }
        
        stage('Terraform Format Check') {
            steps {
                dir('aws-vpc') {
                    script {
                        sh '''
                            echo "Checking Terraform formatting..."
                            terraform fmt -check=true -diff=true
                        '''
                    }
                }
            }
        }
        
        stage('Terraform Plan') {
            when {
                anyOf {
                    expression { params.ACTION == 'plan' }
                    expression { params.ACTION == 'apply' }
                }
            }
            steps {
                dir('aws-vpc') {
                    script {
                        sh '''
                            echo "Running Terraform plan..."
                            terraform plan -out=tfplan -detailed-exitcode
                        '''
                        
                        // Archive the plan file
                        archiveArtifacts artifacts: 'tfplan', fingerprint: true
                    }
                }
            }
        }
        
        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                dir('aws-vpc') {
                    script {
                        if (params.AUTO_APPROVE) {
                            sh '''
                                echo "Applying Terraform plan with auto-approval..."
                                terraform apply -auto-approve tfplan
                            '''
                        } else {
                            timeout(time: 10, unit: 'MINUTES') {
                                input message: 'Do you want to apply the Terraform plan?', ok: 'Apply'
                            }
                            sh '''
                                echo "Applying Terraform plan..."
                                terraform apply tfplan
                            '''
                        }
                    }
                }
            }
        }
        
        stage('Terraform Destroy Plan') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                dir('aws-vpc') {
                    script {
                        sh '''
                            echo "Creating Terraform destroy plan..."
                            terraform plan -destroy -out=tfdestroy
                        '''
                        
                        // Archive the destroy plan file
                        archiveArtifacts artifacts: 'tfdestroy', fingerprint: true
                    }
                }
            }
        }
        
        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                dir('aws-vpc') {
                    script {
                        if (params.AUTO_APPROVE) {
                            sh '''
                                echo "Destroying infrastructure with auto-approval..."
                                terraform apply -auto-approve tfdestroy
                            '''
                        } else {
                            timeout(time: 10, unit: 'MINUTES') {
                                input message: 'Are you sure you want to destroy the infrastructure?', ok: 'Destroy'
                            }
                            sh '''
                                echo "Destroying infrastructure..."
                                terraform apply tfdestroy
                            '''
                        }
                    }
                }
            }
        }
        
        stage('Output Infrastructure Details') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                dir('aws-vpc') {
                    script {
                        sh '''
                            echo "Terraform outputs:"
                            terraform output
                        '''
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Clean up temporary files
            dir('aws-vpc') {
                sh '''
                    rm -f tfplan tfdestroy
                    rm -f terraform.tfstate.backup
                '''
            }
        }
        
        success {
            echo "Pipeline completed successfully!"
            // Send success notification if needed
        }
        
        failure {
            echo "Pipeline failed!"
            // Send failure notification if needed
        }
        
        cleanup {
            // Clean workspace
            cleanWs()
        }
    }
}
