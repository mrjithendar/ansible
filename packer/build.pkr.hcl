data "amazon-ami" "amazonLinux2" {
  filters = {
    name = "Amazon Linux 2023 AMI"
  }
  most_recent = true
  owners      = ["amazon"]
  region      = var.aws_region
}

source "amazon-ebs" "amazonLinux2" {
  ami_name       = "roboshop-{{timestamp}}"
  instance_type  = "t3.large"
  region         = var.aws_region
  source_ami     = data.amazon-ami.amazonLinux2.id
//   user_data_file = "./scripts/WinrmSetup.ps1"
  ssh_port = 22
  ssh_username = "ec2-user"

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 40
    volume_type           = "gp2"
    delete_on_termination = true
  }

  temporary_iam_instance_profile_policy_document {
    Version = "2012-10-17"
    Statement {
        Effect = "Allow"
        Action = ["*"]
        Resource = ["*"]
    }
  }

  tags = {
    Name    = "{{ .Ami_Name }}"
    Base_AMI_Name = "{{ .SourceAMIName }}"
  }
}

build {
  sources = ["source.amazon-ebs.amazonLinux2"]

  provisioner "file" {
    source      = "./scripts/patch.sh"
    destination = "/tmp/patch.sh"
  }
  
  provisioner "shell" {
    inline = [
      "id"
    ]
  }

  provisioner "shell" {
    script = "/tmp/script.sh"
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }

}