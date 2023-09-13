resource "aws_instance" "instance" {
  depends_on = [ 
    aws_security_group.roboshop, 
    aws_subnet.private_subnets, 
    aws_subnet.public_subnets 
    ]
  count         = length(var.COMPONENT)
  ami           = data.aws_ami.AMI.id
  instance_type = var.INSTANCE_TYPE
  vpc_security_group_ids = [ aws_security_group.roboshop.id ]
  subnet_id = aws_subnet.private_subnets[0].id
  user_data = "set hostname ${element(var.COMPONENT, count.index)}"
  tags = (merge(local.common_tags, tomap({
    "Name"    = "${element(var.COMPONENT, count.index)}",
    "Purpose" = "Roboshop App Component ${element(var.COMPONENT, count.index)} and ${local.common_tags["Team"]}"
  })))
}