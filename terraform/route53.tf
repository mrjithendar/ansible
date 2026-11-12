resource "aws_route53_zone" "app_roboshop" {
  name = "roboshop.com"
  vpc {
    vpc_id = aws_vpc.roboshop.id
  }
}

resource "aws_route53_record" "app_roboshop" {
  for_each        = aws_instance.instance
  allow_overwrite = true
  name            = "${each.key}.${aws_route53_zone.app_roboshop.name}"
  zone_id         = aws_route53_zone.app_roboshop.zone_id
  type            = "A"
  ttl             = 300
  records         = [each.value.private_ip]
}

resource "aws_route53_record" "redis_roboshop" {
  name    = "redis.${aws_route53_zone.app_roboshop.name}"
  type    = "CNAME"
  zone_id = aws_route53_zone.app_roboshop.zone_id
  ttl     = 300
  records = [aws_elasticache_replication_group.roboshop.primary_endpoint_address]
}

resource "aws_route53_record" "rds_roboshop" {
  name    = "mysql.${aws_route53_zone.app_roboshop.name}"
  type    = "CNAME"
  ttl     = 300
  zone_id = aws_route53_zone.app_roboshop.zone_id
  records = [aws_rds_cluster.roboshop.endpoint]
}
