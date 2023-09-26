#!/bin/bash

sudo yum update -y

echo "enabling root login with password::: Jithendar"
sudo sed -i 's\PasswordAuthentication no\PasswordAuthentication yes\g' /etc/ssh/sshd_config
sudo cat /etc/ssh/sshd_config | grep "PasswordAuthentication"
sudo sed -i 's\#PermitRootLogin prohibit-password\PermitRootLogin yes\g' /etc/ssh/sshd_config
sudo cat /etc/ssh/sshd_config | grep "PermitRootLogin"

sudo sed -i 's\disable_root: true\disable_root: false\g' /etc/cloud/cloud.cfg
sudo cat /etc/cloud/cloud.cfg | grep disable_root

sudo sed -i 's\ssh_pwauth:   false\ssh_pwauth:   true\g' /etc/cloud/cloud.cfg
sudo cat /etc/cloud/cloud.cfg | grep ssh_pwauth

echo "setting root password"
echo "Jithendar" | sudo passwd --stdin root

sudo systemctl restart sshd

sudo yum -y install git vim zip jq wget make cmake gcc bzip2-devel libffi-devel zlib-devel openssl-devel 
sudo yum -y groupinstall "Development Tools"

echo "Installing Docker and Docker-Compose"
sudo yum install docker -y
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose version

sudo yum install -y python3.11 python3.11-pip
curl -O https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py --user

## TERRAFORM INSTALALTION ##
echo "installing Terraform latest"
sudo yum install -y yum-utils
sudo sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
echo "installed terraform $(terraform -version)"