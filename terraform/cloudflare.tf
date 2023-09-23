terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_token = "Ob_vRDNWhun1f8FzO154mr_hAbh72ZOZl8pmx5qS"
}

resource "cloudflare_record" "roboshop" {
  zone_id = data.cloudflare_zone.jithendar.id
  name    = "roboshop"
  value   = aws_instance.instance[7].public_ip
  type    = "A"
  proxied = true
}