# Worker variables
variable "worker_desired_count" {
  default     = 2
  description = "The number of worker boxes to run. Defaults to a pair."
}

variable "worker_min_count" {
  default     = 1
  description = "The minimum number of web boxes to run. Defaults to one."
}

variable "worker_max_count" {
  default     = 2
  description = "The maximum number of web boxes to run. Defaults to a pair."
}

variable "worker_private_subnets" {
  type        = list(string)
  description = "The subnet IDs you'll be installing concourse worker boxes into. Again, we make no assumptions. This should be large enough to support your cluster."
}

variable "worker_instance_type" {
  description = "The worker instance types. Pick something kinda big but not huge."
}

variable "worker_vol_size" {
  default     = 40
  description = "We'll assign instance volumes of this size to your workers. Suggested retail size of 40GB."
}

variable "worker_container_storage_driver" {
  default     = "overlay"
  description = "Storage driver to use for the container runtime. Defaults to overlay."
}

variable "worker_patch_schedule" {
  description = "The frequency to patch worker machines. Use AWS cron syntax."
}

variable "worker_dns_servers" {
  default     = ["8.8.8.8", "8.8.4.4"]
  description = "Optional DNS servers. Defaults to google."
}

variable "worker_feature_flags" {
  type        = list(string)
  default     = []
  description = "Pass feature flag options here as a list of key value environment variables. Defaults to nothing."
}
