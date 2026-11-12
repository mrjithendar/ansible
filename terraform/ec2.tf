resource "aws_instance" "instance" {
  for_each = toset(var.COMPONENT)

  ami                    = data.aws_ami.ami.id
  instance_type          = var.instancetype
  key_name               = aws_key_pair.roboshop.key_name
  subnet_id              = aws_subnet.public_subnet_1.id
  vpc_security_group_ids = concat(
    [aws_security_group.app.id],
    each.key == "frontend" ? [aws_security_group.web.id] : []
  )

  user_data = <<-EOF
    #!/bin/bash
    hostnamectl set-hostname ${each.key}
  EOF

  metadata_options {
    http_tokens = "required" # IMDSv2 only
  }

  root_block_device {
    encrypted = true
  }

  tags = (merge(local.common_tags, tomap({
    "Name"      = each.key,
    "Component" = each.key,
    "Purpose"   = "Roboshop App Component ${each.key} and ${local.common_tags["Team"]}"
  })))
}

output "instance_public_ips" {
  description = "Public IP of each component host."
  value       = { for k, i in aws_instance.instance : k => i.public_ip }
}
