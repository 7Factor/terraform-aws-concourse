variable cluster_name {
  description = "Name your cluster! This will show up in tags."
}

variable vpc_id {
  description = "The ID of the VPC you'll be installing concourse into. We make no assumptions about your networking stack, so you should provide this."
}

variable subnet_id {
  description = "The subnet ID you'll be installing concourse into. Again, we make no assumptions. This should be large enough to support your cluster."
}

variable conc_ssh_key_name {
  description = "The PEM key name for accessing and provisioning stuff."
}

variable conc_image {
  default     = "concourse/concourse"
  description = "The image name for concourse. Defaults to latest, but you should lock this down."
}

# security group variables
variable conc_web_ingress_cidr {
  default     = "0.0.0.0/0"
  description = "The CIDR block from whence web traffic may come. Defaults to anywhere, but override it as necessary. This is applied to the ELB."
}

variable conc_ssh_ingress_cidr {
  description = "The CIDR block from whence SSH traffic may come. Set this to your bastion host or your VPN IP range."
}

variable conc_db_instance_type {
  description = "The instance type for our teensy DB server. We don't use RDS because it's expensive and heavy."
}

variable conc_db_pw {
  description = "The password for the postgres user. Make sure this is secret and safe."
}

variable conc_web_instance_type {
  description = "The web instance type. Usually around an m3.large gets it done, but do what you want."
}

variable conc_web_count {
  default     = 2
  description = "The number of web boxes to run. Defaults to a pair."
}

variable conc_web_cert_arn {
  description = "The ARN to the SSL cert we'll apply to the ELB."
}

variable conc_fqdn {
  description = "The FQDN where your cluster will live. Point this via your DNS to the ELB DNS provided in the output of this module otherwise you'll get some wonkiness."
}

variable conc_web_keys_dir {
  description = "The path to the keys you should generate for the web boxes in order to allow the workers and web boxes to talk. See documentation."
}

# Auth defaults to none, but you should override it
variable authentication_config {
  default     = "--no-really-i-dont-want-any-auth"
  description = "Toss your authentication scheme here. See documentation. Defaults to no auth."
}

# Worker variables
variable conc_worker_keys_dir {
  description = "The path to the keys you should generate for workers so they can talk to the web boxes. See documentation."
}

variable conc_worker_count {
  default     = 2
  description = "The number of worker boxes to spin up. Defaults to 2."
}

variable conc_worker_instance_type {
  description = "The worker instance types. Pick something kinda big but not huge."
}

variable conc_worker_vol_size {
  default     = 40
  description = "We'll assign instance volumes of this size to your workers. Suggested retail size of 40GB."
}
