# sudo vim /etc/ssh/sshd_config
# PermitRootLogin yes
# PasswordAuthentication yes
# sudo systemctl restart sshd

sudo yum update -y

# sudo yum -y install epel-release
sudo yum install git vim zip jq cockpit wget make cmake gcc bzip2-devel libffi-devel zlib-devel openssl-devel
sudo yum -y groupinstall "Development Tools"

sudo yum update -y

sudo yum install -y python3.11 python3.11-pip

sudo pip install awscli boto3 ansible