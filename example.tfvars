# The bare minimum required to run this module is provided in this
# example file. Be sure to not store sensitive information in the
# fields pertaining to passwords, authentication configuration, and
# cred store configuration.

###########################
# CONCOURSE MODULE CONFIG #
###########################

vpc_id = "VPC-ID"

conc_version    = "5.1.0"
concdb_password = "SUPER-SECRET-PW"

# SSH config
conc_key_name         = "concourse-dev-us-east-1"
conc_key_path         = "keys"
utility_sg            = "UTILITY-SG"
utility_accessible_sg = "UTILITY-ACCESSIBLE-SG"

# Web config
lb_security_policy  = "ELBSecurityPolicy-2016-08"
web_public_subnets  = ["WEB-PUB-SUBNET-1", "WEB-PUB-SUBNET-2"]
web_private_subnets = ["WEB-PRIV-SUBNET-1", "WEB-PRIV-SUBNET-2"]
web_ingress_cidr    = "0.0.0.0/0"
web_instance_type   = "t3.micro"

conc_web_cert_arn = "CERT-ARN"
web_desired_count = 2
conc_fqdn         = "ci.7fdev.io"

# Auth
authentication_config = "AUTHENTICATION-CONFIG"
cred_store_config     = "CRED-STORE-CONFIG"

# Worker config
worker_private_subnets = ["WORKER-PRIV-SUBNET-1", "WORKER-PRIV-SUBNET-2"]
worker_instance_type   = "t3.medium"
worker_count           = 2

# Keys directories
web_keys_dir    = "./keys/web/"
worker_keys_dir = "./keys/worker/"
