pipeline {

    agent any

    parameters {
        choice(name: 'Ansible', choices: ['CreateApp', 'DeleteApp', 'Invoke_playbook'], description: 'Pick any action')
               }

    environment {
        tfDir = "terraform"
        region = "us-east-1"
    }

    stages {

        stage('Create Infra with Terraform') {
            when { expression {params.Ansible == "CreateApp" } }
            // tools {terraform 'terraform'}
            steps {
                withAWS(credentials: 'AWSCred', region: "${region}") {
                    sh "terraform --version"
                    sh "terraform -chdir=${tfDir} init -reconfigure"
                    sh "terraform -chdir=${tfDir} validate"
                    sh "terraform -chdir=${tfDir} plan -out=planfile"
                    sh "terraform -chdir=${tfDir} apply planfile"

                    // sh "terraform -chdir=${tfDir} destroy --auto-approve"
                }
            }
        }

        stage('Delete Infra with Terraform') {
            when { expression {params.Ansible == "DeleteApp" } }
            // tools {terraform 'terraform'}
            steps {
                withAWS(credentials: 'AWSCred', region: "${region}") {
                    sh "terraform --version"
                    sh "terraform -chdir=${tfDir} init -reconfigure"
                    sh "terraform -chdir=${tfDir} validate"
                    sh "terraform -chdir=${tfDir} destroy --auto-approve"
                }
            }
        }

        stage('Make Ansible Inventery') {
            when { expression {params.Ansible == "CreateApp" } }
            steps {
                withAWS(credentials: 'AWSCred', region: "${region}") {
                    sh "sleep 10" // let the ec2 instances fully ready
                    sh "chmod +x mkinv.sh"
                    sh '''
                    awk '{ sub("\r$", ""); print }' mkinv.sh > newmkinv.sh
                    '''
                    sh "chmod +x newmkinv.sh"
                    sh 'bash newmkinv.sh'
                    sh "chmod 600 roboshop.pem"
                }
            }
        }

        stage ('Installing DB & Cache Service') {
            // Install MySQL MongoDB RabbitMQ Redis
            when { expression {params.Ansible == "CreateApp"} }
            parallel {
                // stage ('Installing MySQL') {
                //     steps {
                //         ansiblePlaybook become: true, credentialsId: 'roboShop', installation: 'ansible', inventory: 'inv', playbook: 'roboshop.yml', tags: 'mysql'
                //     }
                // }
                stage ('Istalling MongoDB') {
                    steps {
                        ansiblePlaybook installation: 'ansible', inventory: 'inv', playbook: 'roboshop.yml', tags: 'mongodb'
                        }
                    }
                stage ('Installing RabbitMQ Server') {
                    steps {
                        ansiblePlaybook installation: 'ansible', inventory: 'inv', playbook: 'roboshop.yml', tags: 'rabbitmq'
                        }
                    }
                // stage ('Installing Redis') {
                //     steps {
                //         ansiblePlaybook installation: 'ansible', inventory: 'inv', playbook: 'roboshop.yml', tags: 'redis'
                //     }
                // }
            }
        }

        stage ('Installing Roboshop MicroServices') {
            // Cart Catalogue User Shipping
            when { expression {params.Ansible == "CreateApp" } }
            parallel {
            stage ('Installing Cart Service') {
                steps {
                    ansiblePlaybook installation: 'ansible', inventory: 'inv', playbook: 'roboshop.yml', tags: 'cart'
                }
            }
            stage ('Installing Catalogue Service') {
                steps {
                    ansiblePlaybook installation: 'ansible', inventory: 'inv', playbook: 'roboshop.yml', tags: 'catalogue'
                }
            }
            stage ('Installing User Service') {
                steps {
                    ansiblePlaybook installation: 'ansible', inventory: 'inv', playbook: 'roboshop.yml', tags: 'user'
                }
            }
            stage ('Installing Shipping Service') {
                steps {
                    ansiblePlaybook installation: 'ansible', inventory: 'inv', playbook: 'roboshop.yml', tags: 'shipping'
                }
            }
            stage ('Installing Payment Service') {
                steps {
                    ansiblePlaybook installation: 'ansible', inventory: 'inv', playbook: 'roboshop.yml', tags: 'payment'
                    }
                }
            }
        }

        stage ('Installing Web Components') {
            // Nginx Web Server
            when { expression {params.Ansible == "CreateApp" } }
            steps {
                ansiblePlaybook installation: 'ansible', inventory: 'inv', playbook: 'roboshop.yml', tags: 'frontend'
            }
        }
    }
}
