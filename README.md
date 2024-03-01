# Concourse on AWS via Terraform

This module will allow you to publish concourse on your own AWS infrastructure. Why another module? We needed something
a little more prescriptive than the current module that's available (don't get us wrong, it's great) so we built this.
It's a very straightforward deploy and will work in enterprise or startup situations. Proper networking design is left
up to the reader but we do assume high availability.

**It is very important that you use concourse version 5.1.0 or higher with this module**. The development team at
concourse can sometimes introduce breaking changes to the docker images when refactoring the CLI. As with most software
engineering projects sometimes we don't catch that in time and our terraform will break during the deployment step and
we have to poke about in the EC2 machines to solve it. We can guarantee that this terraform works with the versions of
concourse specified above.

Currently we support the following features:

1. Configurable number of workers and web nodes. Everything has a sane default but customize to your liking.
2. Requires AWS classic load balancing complete with SSL termination. Classic ELBs are required because we need the 
ability to service weird ports like 2222. ALBs support only HTTPS/HTTP and network LBs don't allow SSL termination.
3. Configurable authentication scheme (you need to know what you're doing though). Pass your secrets through the
appropriate configuration variable and we'll pass that to the docker container.
4. Configurable cred store. Pass in your credential store switches through the appropriate variable and you'll be up and
running in no time.

Most of what you need to know is provided in an example tfvars file, and feel free to peruse the `variables.tf` for
documentation on the required variables to run the terraform.

For persistent storage we usually combine this module with an outer shell that provisions an RDS PostgreSQL instance and
we pass the credentials in securely. We do this because it allows us to segregate the RDS instance from concourse so if
we need to blow away the concourse instance we can without worrying about having to reprovision a database.

This module should be fairly set-and-forget as we've put a lot of man hours into improving it. Feel free to hit us up
via email or fork this repo and send PRs if you can think of a way to improve it!

## Example Usage

```hcl-terraform
module "concourse" {
  source  = "7Factor/concourse/aws"
  version = "~> 2"

  # Common config
  cluster_name = "${var.conc_cluster_name}"
  vpc_id       = "${var.vpc_id}"
  conc_version = "${var.conc_version}"

  # SSH config
  conc_ssh_key_name     = "${var.conc_ssh_key_name}"
  utility_accessible_sg = "${var.utility_accessible_sg}"

  # DB configuration
  concdb_host     = "${aws_db_instance.concourse_db.address}"
  concdb_password = "${var.concdb_password}"

  # Web configuration
  web_instance_type   = "${var.web_instance_type}"
  web_count           = "${var.web_count}"
  web_cert_arn        = "${var.conc_web_cert_arn}"
  web_keys_dir        = "${path.root}/keys/web/"
  web_public_subnets  = "${var.web_private_subnets}"
  web_private_subnets = "${var.web_private_subnets}"
  fqdn                = "${var.fqdn}"
  internal            = "${var.internal}"

  # auth/security
  authentication_config  = "${var.authentication_config}"
  web_lb_security_policy = "${var.lb_security_policy}"

  # Worker
  worker_count            = "${var.worker_count}"
  worker_instance_type    = "${var.worker_instance_type}"
  worker_keys_dir         = "${path.root}/keys/worker/"
  worker_vol_size         = "${var.worker_vol_size}"
  worker_subnets          = "${var.worker_subnets}"
  worker_instance_profile = "${aws_iam_instance_profile.concourse_profile.name}"

  # Vault
  cred_store_config = "${var.cred_store_config}"
}
```

## Migrating to Terraform Registry version

We have migrated this module to the
[Terraform Registry](https://registry.terraform.io/modules/7Factor/concourse/aws/latest)! Going forward, you should
endeavour to use the registry as the source for this module. It is also **highly recommended** that you migrate existing
projects to the new source at your earliest convenience. Using it in this way, you can select a range of versions to use
in your service which allows us to make potentially breaking changes to the module without breaking your service.

**Note:** The development for version 2 and higher of this module will continue on the `main` branch rather than
`master`. This is to ensure that existing users of the module are not affected by breaking changes. We will continue to
maintain the `master` branch for bug fixes and security patches.

### Migration instructions

You need to change the module source from the GitHub url to `7Factor/concourse/aws`. This will pull the module from
the Terraform registry. You should also add a version to the module block. See the [example](#example-usage) above for
what this looks like together.

**Major version 1 is intended to maintain backwards compatibility with the old module source.** To use the new module
source and maintain compatibility, set your version to `"~> 1"`. This means you will receive any updates that are
backwards compatible with the old module.
