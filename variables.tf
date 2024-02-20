variable "lb_internal" {
  default     = false
  description = "Whether or not the concourse web load balancer is internal or not"
}

variable "vpc_id" {
  description = "The ID of the VPC you'll be installing concourse into. We make no assumptions about your networking stack, so you should provide this."
}

variable "conc_key_name" {
  description = "The PEM key name for accessing and provisioning web and worker boxes."
}

variable "conc_version" {
  default     = "5.1.0"
  description = "The image name for concourse. Defaults to latest, but you should lock this down."
}

variable "base_ami_name_filter" {
  default     = ["amzn2-ami-hvm-*-x86_64-ebs"]
  description = "Name filter for the base ami for Concourse machines. Defaults to Amazon Linux 2 AMI (HVM). View the AWS docs for more info."
}

variable "concdb_host" {
  description = "Concourse database host name. Required in the new 4.1 build."
}

variable "concdb_port" {
  default     = 5432
  description = "Concourse database port. Override if you really need to, defaults to what you'd expect."
}

variable "concdb_user" {
  default     = "concourse"
  description = "Concourse DB username. Defaults to the old value for backward compatibility with older concourse installs, but change it to what you want."
}

variable "concdb_password" {
  description = "Concourse DB password. required in the new 4.1 build. Beware special characters."
}

variable "concdb_database" {
  default     = "concourse"
  description = "Concourse DB name. Defaults to the old value for backward compatibility."
}

variable "utility_accessible_sg" {
  description = "Pass in the ID of your access security group here."
}

variable "schedule_timezone" {
  default     = "America/New_York"
  description = "The timezone inside of which to run the patch windows."
}

variable "custom_policy_arns" {
  type        = list(string)
  description = "Pass in a list of policy ARNs to assign to the concourse IAM role."
}

variable "prometheus_enabled" {
  default     = false
  description = "Whether or not to enable prometheus monitoring for concourse."
}

variable "prometheus_bind_port" {
  default     = 9100
  description = "The port to bind prometheus to."
}

variable "cloudwatch_namespace" {
  default     = "Concourse"
  description = "The namespace to use for CloudWatch metrics."
}
