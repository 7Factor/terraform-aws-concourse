# Required terraform version
terraform {
  required_version = ">=0.10.7"
}

# Grab the current region to be used everywhere
data "aws_region" "current" {}

data "aws_ami" "aws_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}
