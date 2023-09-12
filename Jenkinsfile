pipeline {

    agent any

    parameters {
        choice(name: 'Ansible', choices: ['Create_Infra', 'Make_inventory', 'Update_routes', 'Invoke_playbook'], description: 'Pick any action')
               }

    environment {
        tfDir = "terraform"
        region = "us-east-1"
    }

    stages {
        stage('create Infra') {
            when { expression {params.Ansible == "Create_Infra" } }
            // tools {terraform 'terraform'}
            steps {
                withAWS(credentials: 'AWSCred', region: "${region}") {
                    script {
                        docker.image('hashicorp/terraform:latest').inside("--entrypoint=''") {
                            sh "terraform -chdir=${tfDir} init -reconfigure"
                            sh "terraform -chdir=${tfDir} destroy --auto-approve"
                            // sh "terraform -chdir=${tfDir} validate"
                            // sh "terraform -chdir=${tfDir} plan -out=planfile"
                            // sh "terraform -chdir=${tfDir} apply planfile"
                        }
                    }
                }
            }
        }
        // stage ('Creating Instances') {
        //     when { expression {params.Ansible == "Create_Infra" } }
        //     steps {
        //         sh "sh instances.sh launch"
        //     }
        // }
        // stage ('Update Routes') {
        //     when { expression {params.Ansible == "Update_routes" } }
        //     steps {
        //         sh "sh instances.sh routes"
        //     }
        // }
        // stage ('Make Inventory') {
        //     when { expression {params.Ansible == "Make_inventory" } }
        //     steps {
        //         sh "sh mkinv.sh"
        //     }
        // }
        stage ('Installing DB & Cache Service') {
            when { expression {params.Ansible == "Invoke_playbook" } }
            parallel {
                stage ('Installing MySQL') {
                    steps {
                        ansiblePlaybook credentialsId: 'DevOps321', installation: 'ansibletool', inventory: '/tmp/inv', playbook: 'roboshop.yml', tags: 'mysql'
                    }
                }
                stage ('Istalling MongoDB') {
                    steps {
                        ansiblePlaybook credentialsId: 'DevOps321', installation: 'ansibletool', inventory: '/tmp/inv', playbook: 'roboshop.yml', tags: 'mongo'
                    }
                }
                stage ('Installing RabbitMQ Server') {
                    steps {
                    ansiblePlaybook credentialsId: 'DevOps321', installation: 'ansibletool', inventory: '/tmp/inv', playbook: 'roboshop.yml', tags: 'rabbitmq'
                    }
                }
                stage ('Installing redis') {
                    steps {
                    ansiblePlaybook credentialsId: 'DevOps321', installation: 'ansibletool', inventory: '/tmp/inv', playbook: 'roboshop.yml', tags: 'redis'
                    }
                }
              }
            }
            stage ('Installing Roboshop MicroServices') {
                when { expression {params.Ansible == "Invoke_playbook" } }
                parallel {
                stage ('Installing Cart Service') {
                    steps {
                        ansiblePlaybook credentialsId: 'DevOps321', installation: 'ansibletool', inventory: '/tmp/inv', playbook: 'roboshop.yml', tags: 'cart'
                    }
                }
                stage ('Installing Catalogue Service') {
                    steps {
                        ansiblePlaybook credentialsId: 'DevOps321', installation: 'ansibletool', inventory: '/tmp/inv', playbook: 'roboshop.yml', tags: 'catalogue'
                    }
                }
                stage ('Installing User Service') {
                    steps {
                        ansiblePlaybook credentialsId: 'DevOps321', installation: 'ansibletool', inventory: '/tmp/inv', playbook: 'roboshop.yml', tags: 'user'
                    }
                }
                stage ('Installing Shipping Service') {
                    steps {
                        ansiblePlaybook credentialsId: 'DevOps321', installation: 'ansibletool', inventory: '/tmp/inv', playbook: 'roboshop.yml', tags: 'shipping'
                    }
                }
                stage ('Installing Payment Service') {
                    steps {
                        ansiblePlaybook credentialsId: 'DevOps321', installation: 'ansibletool', inventory: '/tmp/inv', playbook: 'roboshop.yml', tags: 'payment'
                            }
                        }
                    }
                }
            stage ('Installing Web Components') {
                when { expression {params.Ansible == "Invoke_playbook" } }
                steps {
                    ansiblePlaybook credentialsId: 'DevOps321', installation: 'ansibletool', inventory: '/tmp/inv', playbook: 'roboshop.yml', tags: 'frontend'
                }
            }
        }
    }
