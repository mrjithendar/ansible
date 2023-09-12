resource "null_resource" "make_inv_file" {
  count   = length(aws_instance.instance)
  provisioner "local-exec" {
    command = "sh ../mkinv.sh"
    #command = "echo ${element(aws_instance.instance, count.index).private_ip} component=${element(var.COMPONENT, count.index)} >> /tmp/inv.txt"
    #command = "sed -i s/env/${var.ENV}/g inv.sh"
  }
}