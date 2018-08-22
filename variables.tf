variable cluster_name {
  description = "Name your cluster! This will show up in tags."
}

variable vpc_id {
  description = "The ID of the VPC you'll be installing concourse into. We make no assumptions about your networking stack, so you should provide this."
}

variable conc_ssh_key_name {
  description = "The PEM key name for accessing and provisioning web and worker boxes."
}

variable conc_image {
  default     = "concourse/concourse"
  description = "The image name for concourse. Defaults to latest, but you should lock this down."
}

variable postgres_connection {
  description = "The connection string for the postgres database. Make sure this is secret and safe."
}

variable fqdn {
  description = "The FQDN where your cluster will live. Point this via your DNS to the ELB DNS provided in the output of this module otherwise you'll get some wonkiness."
}

variable web_instance_type {
  description = "The web instance type. Usually around an m3.large gets it done, but do what you want."
}

variable web_count {
  default     = 2
  description = "The number of web boxes to run. Defaults to a pair."
}

variable web_public_subnets {
  type        = "list"
  description = "The subnet IDs you'll be installing concourse web boxes into. Again, we make no assumptions. This should be large enough to support your cluster."
}

variable web_cert_arn {
  description = "The ARN to the SSL cert we'll apply to the ELB."
}

variable web_keys_dir {
  description = "The path to the keys you should generate for the web boxes in order to allow the workers and web boxes to talk. See documentation."
}

# Auth defaults to none, but you should override it
variable authentication_config {
  default     = "--no-really-i-dont-want-any-auth"
  description = "Toss your authentication scheme here. See documentation. Defaults to no auth."
}

# Worker variables
variable worker_keys_dir {
  description = "The path to the keys you should generate for workers so they can talk to the web boxes. See documentation."
}

variable worker_count {
  default     = 2
  description = "The number of worker boxes to spin up. Defaults to 2."
}

variable worker_subnets {
  type        = "list"
  description = "The subnet IDs you'll be installing concourse worker boxes into. Again, we make no assumptions. This should be large enough to support your cluster."
}

variable worker_instance_type {
  description = "The worker instance types. Pick something kinda big but not huge."
}

variable worker_vol_size {
  default     = 40
  description = "We'll assign instance volumes of this size to your workers. Suggested retail size of 40GB."
}

variable web_lb_security_policy {
  description = "Load balancer policy string for the HTTPS ALB. Required else AWS will become unhappy."
}

# security group variables
variable web_ingress_cidr {
  default     = "0.0.0.0/0"
  description = "The CIDR block from whence web traffic may come for web boxes servicing traffic from workers. Defaults to anywhere, but override it as necessary. This is applied to the ELB."
}

variable ssh_access_sg {
  description = "Pass in the ID of your SSH access security group here. We recommend this utilizes a bastion host design, but you can easily pass in anything that's a valid SG."
}
