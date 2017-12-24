variable region {}

# Network
variable conc_vpc_id {}
variable conc_subnet_id {}

# Common variables
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

# Auth
variable github_client_id {}
variable github_client_secret {}
variable github_org {}

# Worker variables
variable conc_worker_count {}
variable conc_worker_instance_type {}
variable conc_worker_vol_size {}
variable conc_worker_ingress_cidr {}
