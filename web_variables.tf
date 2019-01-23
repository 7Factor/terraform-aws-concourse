variable web_instance_type {
  description = "The web instance type. Usually around an m3.large gets it done, but do what you want."
}

variable web_instance_profile_arn {
  description = "Name of the instance profile and corresponding policies. We split this off because it changes pretty often."
}

variable web_desired_count {
  default     = 2
  description = "The number of web boxes to run. Defaults to a pair."
}

variable web_min_count {
  default     = 1
  description = "The minimum number of web boxes to run. Defaults to one."
}

variable web_max_count {
  default     = 2
  description = "The maximum number of web boxes to run. Defaults to a pair."
}

variable web_public_subnets {
  type        = "list"
  description = "The IDs of public subnets corresponding to private subnets inside which concourse will be installed. Passed to the load balancer."
}

variable web_private_subnets {
  type        = "list"
  description = "The subnet IDs the concourse machines will actually be installed into."
}

variable web_cert_arn {
  description = "The ARN to the SSL cert we'll apply to the ELB."
}

variable web_lb_security_policy {
  description = "Load balancer policy string for the HTTPS ALB. Required else AWS will become unhappy."
}

# security group variables
variable web_ingress_cidr {
  default     = "0.0.0.0/0"
  description = "The CIDR block from whence web traffic may come for web boxes servicing traffic from workers. Defaults to anywhere, but override it as necessary. This is applied to the ELB."
}

variable conc_fqdn {
  description = "The FQDN where your cluster will live. Point this via your DNS to the ELB DNS provided in the output of this module otherwise you'll get some wonkiness. Note that we force HTTPS here so do not include the protocol."
}

variable web_launch_options {
  default     = ""
  description = "Other options to provide to docker containers on run. Only passed to the concourse binary, not the container."
}

variable authentication_config {
  default     = "--main-team-allow-all-users"
  description = "Toss your authentication scheme here. See documentation. Defaults to no auth."
}

variable cred_store_config {
  default     = ""
  description = "Pass options for your target cred store here. Passed to the concourse web binary, not the container."
}
