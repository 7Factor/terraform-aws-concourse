# Worker variables
variable worker_desired_count {
  default     = 2
  description = "The number of worker boxes to run. Defaults to a pair."
}

variable worker_min_count {
  default     = 1
  description = "The minimum number of web boxes to run. Defaults to one."
}

variable worker_max_count {
  default     = 2
  description = "The maximum number of web boxes to run. Defaults to a pair."
}

variable worker_private_subnets {
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

variable worker_instance_profile {
  description = "Name of the instance profile and corresponding policies. We split this off because it changes pretty often."
}

variable worker_key_path {
  description = "Path to an OpenSSH or RSA key the worker uses to secure communication with."
}

variable tsa_public_key_path {
  description = "Path to an OpenSSH or RSA public key the worker uses to talk to the TSA with."
}
