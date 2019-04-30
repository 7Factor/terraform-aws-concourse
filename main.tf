# Required terraform version
terraform {
  required_version = ">=0.10.7"
}

data "aws_ami" "base_ami" {
  most_recent = true
  owners      = ["591542846629"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
