variable "web_instance_type" {
  description = "The web instance type. Usually around an m3.large gets it done, but do what you want."
}

variable "web_desired_count" {
  default     = 2
  description = "The number of web boxes to run. Defaults to a pair."
}

variable "web_min_count" {
  default     = 1
  description = "The minimum number of web boxes to run. Defaults to one."
}

variable "web_max_count" {
  default     = 2
  description = "The maximum number of web boxes to run. Defaults to a pair."
}

variable "web_public_subnets" {
  type        = list(string)
  description = "The IDs of public subnets corresponding to private subnets inside which concourse will be installed. Passed to the load balancer."
}

variable "web_private_subnets" {
  type        = list(string)
  description = "The subnet IDs the concourse machines will actually be installed into."
}

variable "web_cert_arn" {
  description = "The ARN to the SSL cert we'll apply to the ELB."
}

variable "web_lb_security_policy" {
  default     = "ELBSecurityPolicy-FS-2018-06"
  description = "Load balancer policy string for the HTTPS ALB. Required else AWS will become unhappy. Defaults to something sane."
}

variable "web_ingress_cidr" {
  default     = "0.0.0.0/0"
  description = "The CIDR block from whence web traffic may come for web boxes servicing traffic from workers. Defaults to anywhere, but override it as necessary. This is applied to the ELB."
}

variable "conc_fqdn" {
  description = "The FQDN where your cluster will live. Point this via your DNS to the ELB DNS provided in the output of this module otherwise you'll get some wonkiness. Note that we force HTTPS here so do not include the protocol."
}

variable "container_placement_strategy" {
  default     = "volume-locality"
  description = "Set the container placement strategy. Defaults to the concourse default but can be set to one of [volume-locality|random|fewest-build-containers]. See the concourse docs for more info."
}

variable "authentication_config" {
  type        = list(string)
  default     = ["CONCOURSE_ADD_LOCAL_USER=test:test,guest:guest", "CONCOURSE_MAIN_TEAM_LOCAL_USER=test"]
  description = "Toss your authentication scheme here as space separated environment variables. See documentation. Defaults to local users with test/test and guest/guest as credentials."
}

variable "cred_store_config" {
  type        = list(string)
  default     = []
  description = "Pass options for your target cred store here as a list of key value environment variables. Defaults to nothing."
}

variable "web_feature_flags" {
  type        = list(string)
  default     = []
  description = "Pass feature flag options here as a list of key value environment variables. Defaults to nothing."
}

variable "web_patch_schedule" {
  description = "The frequency to patch web machines. Use AWS cron syntax."
}

variable "concourse_base_resource_type_defaults" {
  type        = object({})
  default     = null
  description = "Pass default base resource type options here. Defaults to nothing."
}
