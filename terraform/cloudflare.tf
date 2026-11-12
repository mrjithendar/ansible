resource "cloudflare_record" "roboshop" {
  zone_id = data.cloudflare_zone.jithendar.id
  name    = "roboshop"
  content = aws_instance.instance["frontend"].public_ip
  type    = "A"
  proxied = false
}
