// RoboShop pipeline.
//
// Jenkins credentials this expects:
//   AWSCred                 - AWS access key (Pipeline: AWS Steps plugin)
//   cloudflare-api-token    - Secret text, Cloudflare token with DNS edit on jithendar.com
//   ansible-vault-password  - Secret file, password for group_vars/all/vault.yml
// Agent tools: terraform >= 1.10, ansible-core >= 2.15 + ansible-lint + boto3/botocore, Maven + JDK 11.

pipeline {
    agent any

    options {
        disableConcurrentBuilds()
        timeout(time: 90, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '20'))
    }

    parameters {
        choice(
            name: 'ACTION',
            choices: ['Plan', 'CreateInfra', 'DeployApp', 'DeleteInfra'],
            description: 'Plan: show changes only. CreateInfra: apply Terraform, then deploy. DeployApp: run Ansible against existing hosts. DeleteInfra: destroy everything.'
        )
    }

    environment {
        TF_DIR               = 'terraform'
        AWS_REGION           = 'us-east-1'
        TF_IN_AUTOMATION     = '1'
        TF_INPUT             = '0'
        CLOUDFLARE_API_TOKEN = credentials('cloudflare-api-token')
        ANSIBLE_FORCE_COLOR  = '1'
    }

    stages {
        stage('Lint') {
            steps {
                sh 'ansible-galaxy collection install -r requirements.yml'
                sh 'ansible-lint'
                sh 'terraform fmt -check -recursive ${TF_DIR}'
            }
        }

        stage('Terraform init') {
            when { expression { params.ACTION != 'DeployApp' } }
            steps {
                withAWS(credentials: 'AWSCred', region: "${AWS_REGION}") {
                    sh 'terraform -chdir=${TF_DIR} init -reconfigure'
                    sh 'terraform -chdir=${TF_DIR} validate'
                }
            }
        }

        stage('Terraform plan') {
            when { expression { params.ACTION in ['Plan', 'CreateInfra'] } }
            steps {
                withAWS(credentials: 'AWSCred', region: "${AWS_REGION}") {
                    sh 'terraform -chdir=${TF_DIR} plan -out=tfplan'
                }
            }
        }

        stage('Terraform destroy plan') {
            when { expression { params.ACTION == 'DeleteInfra' } }
            steps {
                withAWS(credentials: 'AWSCred', region: "${AWS_REGION}") {
                    sh 'terraform -chdir=${TF_DIR} plan -destroy -out=tfplan'
                }
            }
        }

        stage('Approve') {
            when { expression { params.ACTION in ['CreateInfra', 'DeleteInfra'] } }
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    input message: "Apply this ${params.ACTION} plan?", ok: 'Apply'
                }
            }
        }

        stage('Terraform apply') {
            when { expression { params.ACTION in ['CreateInfra', 'DeleteInfra'] } }
            steps {
                withAWS(credentials: 'AWSCred', region: "${AWS_REGION}") {
                    sh 'terraform -chdir=${TF_DIR} apply tfplan'
                }
            }
        }

        stage('Build shipping') {
            when { expression { params.ACTION in ['CreateInfra', 'DeployApp'] } }
            steps {
                sh 'mvn -B -q -f roles/shipping/files/pom.xml clean package -DskipTests'
            }
        }

        stage('Deploy RoboShop') {
            when { expression { params.ACTION in ['CreateInfra', 'DeployApp'] } }
            steps {
                withAWS(credentials: 'AWSCred', region: "${AWS_REGION}") {
                    // SSH key comes from Terraform state; never echoed.
                    sh '''
                        terraform -chdir=${TF_DIR} init -reconfigure >/dev/null
                        umask 077
                        terraform -chdir=${TF_DIR} output -raw private_key > roboshop.pem
                    '''
                    ansiblePlaybook(
                        installation: 'ansible',
                        playbook: 'roboshop.yml',
                        inventory: 'inventory/aws_ec2.yml',
                        vaultCredentialsId: 'ansible-vault-password',
                        colorized: true
                    )
                }
            }
        }
    }

    post {
        always {
            sh 'rm -f roboshop.pem ${TF_DIR}/tfplan'
        }
    }
}
