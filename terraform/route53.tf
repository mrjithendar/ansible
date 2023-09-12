# data "aws_route53_zone" "roboshop" {
#   name = "roboshop.com"
#   private_zone = true #true or false
# }

resource "aws_route53_zone" "roboshop" {
  name = "roboshop.com"
  vpc {
    vpc_id = "default"
  }
}

resource "aws_route53_record" "roboshop" {
  count = length(var.COMPONENT)
  allow_overwrite = true
  name       = "${element(var.COMPONENT, count.index)}.${data.aws_route53_zone.jithendar.name}"
  zone_id    = "${data.aws_route53_zone.jithendar.zone_id}"
  type       = "A"
  ttl        = "300"
  records    = ["${element(aws_instance.instance, count.index)}".private_ip]
}