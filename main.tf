terraform {
  required_version = ">=1.2"
}

data "aws_ami" "base_ami" {
  most_recent = true
  owners      = [137112412989]

  filter {
    name   = "name"
    values = [var.base_ami_name_filter]
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
