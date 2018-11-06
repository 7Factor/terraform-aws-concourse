variable internal {
  default     = false
  description = "Whether or not the concourse web load balancer is internal or not"
}

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

variable concdb_host {
  description = "Concourse database host name. Required in the new 4.1 build."
}

variable concdb_port {
  default     = 5432
  description = "Concourse database port. Override if you really need to, defaults to what you'd expect."
}

variable concdb_user {
  default     = "concourse"
  description = "Concourse DB username. Defaults to the old value for backward compatibility with older concourse installs, but change it to what you want."
}

variable concdb_password {
  description = "Concourse DB password. required in th enew 4.1 build."
}

variable concdb_database {
  default     = "concourse"
  description = "Concourse DB name. Defaults to the old value for backward compatibility."
}

# Web variables
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
  description = "The IDs of public subnets corresponding to private subnets inside which concourse will be installed"
}

variable web_private_subnets {
  type        = "list"
  description = "The subnet IDs the concourse machines will actually be installed into."
}

variable web_cert_arn {
  description = "The ARN to the SSL cert we'll apply to the ELB."
}

variable web_keys_dir {
  description = "The path to the keys you should generate for the web boxes in order to allow the workers and web boxes to talk. See documentation."
}

variable authentication_config {
  default     = "--main-team-allow-all-users"
  description = "Toss your authentication scheme here. See documentation. Defaults to no auth."
}

variable cred_store_config {
  default     = ""
  description = "Pass options for your target cred store here. Passed to the concourse web binary, not the container."
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

variable worker_launch_options {
  default     = ""
  description = "Other options to provide to docker containers on run. Passed to the concourse binary, not the container."
}

variable web_lb_security_policy {
  description = "Load balancer policy string for the HTTPS ALB. Required else AWS will become unhappy."
}

variable worker_bind_ip {
  default     = "0.0.0.0"
  description = "Binding IP for all worker components. Passed to --bind-ip, --baggageclaim-bind-ip, and --garden-bind-ip."
}

# security group variables
variable web_ingress_cidr {
  default     = "0.0.0.0/0"
  description = "The CIDR block from whence web traffic may come for web boxes servicing traffic from workers. Defaults to anywhere, but override it as necessary. This is applied to the ELB."
}

variable web_launch_options {
  default     = ""
  description = "Other options to provide to docker containers on run. Only passed to the concourse binary, not the container."
}

variable utility_accessible_sg {
  description = "Pass in the ID of your access security group here."
}
