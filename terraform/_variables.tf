variable "COMPONENT" {}
variable "instancetype" {}
variable "REGION" {}
variable "keypair" {}
variable "amazonami" {}
variable "centos8ami" {}

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

variable "key_name" {
  default = "roboshopkey"
}