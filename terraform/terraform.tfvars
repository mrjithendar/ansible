COMPONENT = [
  # "mysql", alwasy removed
  # "redis", alwasy removed
  "mongo",
  "rabbitmq",
  "cart",
  "catalogue",
  "shipping",
  "payment",
  "user",
  "frontend"
]

instancetype  = "t2.micro"
REGION        = "us-east-1"
amazonami     = "ami-04cb4ca688797756f"
keypair       = "roboshop"
centos8ami    = "ami-0cdb8266fcd5d3d63" 
environment   = "test"
email         = "i@jithendar"
userid        = "jdharmapuri"
vpc_cidr      = "10.0.0.0/16"
key_pair_name = "roboshopkey"