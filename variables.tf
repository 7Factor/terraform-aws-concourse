# The ever required region variable. Set this
# to wherever you want stuff installed.
variable region {}

# The VPC ID where you want the cluster installed.
# We assume you already have this set up (as you should)
variable conc_vpc_id {}

# There's not much need to deploy concourse on seperate subnets.
# Unless you have a very special case give it the subnet where you
# have some room.
variable conc_subnet_id {}

# Name your cluster!
variable cluster_name {}

# Name the SSH key you use for deploying these boxes.
variable conc_ssh_key_name {}

# The image name to pull. Defaults to latest, but feel free to lock this 
# to a specific version (we do).
variable conc_image { default = "concourse/concourse" }

# security group variables
variable conc_web_ingress_cidr {}

# Ingress IP range for ssh access to your concourse cluster. Set this to
# something interesting like a bastion host or your VPN CIDR.
variable conc_ssh_ingress_cidr {}

# The type of DB instance to run. In this deploy we've chosen to not store
# this inside RDS (it's expensive). We use a micro instance and it's fine.
variable conc_db_instance_type {}

# The password to set for the postgres user. You should definitely keep this
# secret and safe.
variable conc_db_pw {}

# Web box instance types. Usually an m3.large gets it done.
variable conc_web_instance_type {}

# The number of web boxes. Usually two gets it done.
variable conc_web_count {}

# The ARN for the cert to apply to the load balancer. Note that we have to 
# use a classic ELB in order to support SSH port 2222 for remote workers.
variable conc_web_cert_arn {}

# The FQDN to set your concourse server to. You need to provide this, and
# if it's not pointed at the generated ELB you might run into some wonkiness.
variable conc_fqdn {}

# Auth defaults to none, but you should add something!
variable authentication_config { default = "--no-really-i-dont-want-any-auth" }

# Total number of concourse workers to deploy
variable conc_worker_count {}

# The instance type for concourse workers
variable conc_worker_instance_type {}

# We recommend using instance storage since it's ephemeral, pluse
# this simplifies your need for deploying EBS volumes
variable conc_worker_vol_size {}
