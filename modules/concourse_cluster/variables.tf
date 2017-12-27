# Common variables
variable region {}

variable cluster_name {}
variable vpc_id {}
variable subnet_id {}

variable conc_ssh_key_name {}
variable conc_image {}

# security group variables
variable conc_web_ingress_cidr {}

variable conc_ssh_ingress_cidr {}

# DB variables
variable conc_db_instance_type {}

variable conc_db_ingress_cidr {}
variable conc_db_pw {}

# Web variables
variable conc_web_instance_type {}

variable conc_web_count {}
variable conc_web_cert_arn {}
variable conc_fqdn {}
variable conc_web_keys_dir {}

# Auth defaults to none, but you should override it
variable authentication_config {}

# Worker variables
variable conc_worker_keys_dir {}

variable conc_worker_count {}
variable conc_worker_instance_type {}
variable conc_worker_vol_size {}
