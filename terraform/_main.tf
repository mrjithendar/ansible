provider "aws" {
  region = var.REGION
}

terraform {
  backend "s3" {
    bucket = "jithendardharmapuri"
    key    = "roboshop/roboshop_absible"
    region = "us-east-1"
  }
}