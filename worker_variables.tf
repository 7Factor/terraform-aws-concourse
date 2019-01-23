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

variable worker_instance_profile {
  description = "Name of the instance profile and corresponding policies. We split this off because it changes pretty often."
}

variable worker_launch_options {
  default     = ""
  description = "Other options to provide to docker containers on run. Passed to the concourse binary, not the container."
}

variable worker_bind_ip {
  default     = "0.0.0.0"
  description = "Binding IP for all worker components. Passed to --bind-ip, --baggageclaim-bind-ip, and --garden-bind-ip."
}