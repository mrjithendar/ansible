resource "tls_private_key" "roboshop" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "roboshop" {
  key_name   = var.key_name
  public_key = tls_private_key.roboshop.public_key_openssh
}

resource "aws_instance" "instance" {
  depends_on = [ 
    aws_security_group.roboshop, 
    aws_subnet.private_subnets, 
    aws_subnet.public_subnets 
    ]
  key_name      = "roboshop"
  count         = length(var.COMPONENT)
  ami           = data.aws_ami.AMI.id #"ami-04cb4ca688797756f" #data.aws_ami.AMI.id
  instance_type = var.INSTANCE_TYPE
  vpc_security_group_ids = [ aws_security_group.roboshop.id ]
  subnet_id = aws_subnet.public_subnets.id #aws_subnet.private_subnets[0].id
  user_data = "set hostname ${element(var.COMPONENT, count.index)}"
  tags = (merge(local.common_tags, tomap({
    "Name"    = "${element(var.COMPONENT, count.index)}",
    "Purpose" = "Roboshop App Component ${element(var.COMPONENT, count.index)} and ${local.common_tags["Team"]}"
  })))
}