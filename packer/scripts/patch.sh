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

sudo yum install -y python3.11 python3.11-pip
curl -O https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py --user

