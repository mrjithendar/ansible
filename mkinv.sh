#!/bin/sh
> /tmp/inv
for component in frontend catalogue cart user shipping payment mysql mongodb redis rabbitmq; do
        IP=$(aws ec2 describe-instances --filters Name=tag:Name,Values=${component} Name=instance-state-name,Values=running | jq '.Reservations[].Instances[].PublicIpAddress' |xargs)
        if [ -n "${IP}" ]; then
                echo $IP component=${component} ansible_user=root ansible_password=DevOps321 >> /tmp/inv
        fi
done

echo "Ansible Inventory"

echo "Ansible Inventory:::"
ansible-inventory --list -y

echo "Ping test on Ansible Inventory:::"
ansible all -m ping -u root

#ansible all -a "df -h" -u root
#ansible all -m apt -a "name=vim state=latest" -u root
#ansible servers -a "uptime" -u root
#ansible server1:server2 -m ping -u root