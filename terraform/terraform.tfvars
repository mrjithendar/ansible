COMPONENT = [
  "mongodb",
  "rabbitmq",
  "cart",
  "catalogue",
  "shipping",
  "payment",
  "user",
  "frontend"
]

instancetype  = "t3.micro"
REGION        = "us-east-1"
environment   = "test"
email         = "i@jithendar"
userid        = "jdharmapuri"
vpc_cidr      = "10.0.0.0/16"
key_pair_name = "roboshopkey"
level         = "pro"

# SSH is only allowed from these CIDRs. Replace with your Jenkins agent's and
# workstation's public IPs (e.g. "203.0.113.10/32"); plan fails until you do.
admin_cidrs = ["CHANGE_ME/32"]
