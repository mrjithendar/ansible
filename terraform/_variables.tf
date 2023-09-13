variable "COMPONENT" {}
variable "INSTANCE_TYPE" {}
variable "REGION" {}
variable "private_instance_per_subnet" {}

variable "environment" {
  default = "test"
}

variable "email" {
  default = "i@jithendar.com"
}

variable "userid" {
  default = "jithendar"
}

variable "level" {
  default = "trainer"
}

variable "vpc_cidr" {
  description = "CIDR Block for VPC"
  default     = "10.0.0.0/16"
}