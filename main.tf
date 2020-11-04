terraform {
  required_version = ">=0.12.3"
}

# Swapping to a tied down ubuntu version for stability.
data "aws_ami" "base_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = var.base_ami_name_filter
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
