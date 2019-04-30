# Required terraform version
terraform {
  required_version = ">=0.10.7"
}

# Swapping to a tied down ubuntu version for stability.
data "aws_ami" "base_ami" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}
