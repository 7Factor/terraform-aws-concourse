# Required terraform version
terraform {
  required_version = ">=0.10.7"
}

# Swapping to a tied down ubuntu version for stability.
data "aws_ami" "base_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
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
