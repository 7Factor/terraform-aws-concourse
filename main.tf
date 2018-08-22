# Required terraform version
terraform {
  required_version = ">=0.10.7"
}

# Grab the current region to be used everywhere
data "aws_region" "current" {}

#---------------------------------------------------------
# Concourse web server farm. We'll go with a passed in
# number of boxes and a load balancer.
#---------------------------------------------------------
data "aws_ami" "ecs_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
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
