resource "aws_route53_zone" "roboshop" {
  name = "roboshop.com"
  vpc {
    vpc_id = "vpc-072846ab623e450ba"
  }
}

resource "aws_route53_record" "roboshop" {
  count = length(var.COMPONENT)
  allow_overwrite = true
  name       = "${element(var.COMPONENT, count.index)}.${aws_route53_zone.roboshop.name}"
  zone_id    = aws_route53_zone.roboshop.zone_id
  type       = "A"
  ttl        = "300"
  records    = ["${element(aws_instance.instance, count.index)}".private_ip]
}