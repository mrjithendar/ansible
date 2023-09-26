data "amazon-ami" "windows_2019" {
  filters = {
    name = "${var.amazon_ami_base}-*"
  }
  most_recent = true
  owners      = ["amazon"]
  region      = var.aws_region
}

source "amazon-ebs" "windows-2019" {
  ami_name       = "${var.ami_prefix}-${var.amazon_ami_base}-{{timestamp}}"
  communicator   = "winrm"
  instance_type  = "t3.large"
  region         = var.aws_region
  source_ami     = "${data.amazon-ami.windows_2019.id}"
  user_data_file = "./scripts/WinrmSetup.ps1"
  winrm_insecure = true
  winrm_use_ssl  = true
  winrm_username = "Administrator"

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 80
    volume_type           = "gp2"
    delete_on_termination = true
  }
  launch_block_device_mappings {
    device_name           = "/dev/sda2"
    volume_size           = 200
    volume_type           = "gp2"
    delete_on_termination = true
  }

  temporary_iam_instance_profile_policy_document {
    Version = "2012-10-17"
    Statement {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
        ]
        Resource = ["*"]
    }
    Statement {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",          
          "ssm:DescribeParameters",          
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
        ]
        Resource = ["*"]
    }
  }

  tags = {
    OS_Version    = "${data.amazon-ami.windows_2019.id}"
    Base_AMI_Name = "{{ .SourceAMIName }}"
    System        = var.system
  }
}