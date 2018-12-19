# Concourse on AWS via Terraform

This module will allow you to publish concourse on your own AWS infrastructure. Why another module? We needed something a little more prescriptive than the current module that's available (don't get us wrong, it's great) so we built this. It's a very straightforward deploy and will work in enterprise or startup situations. Proper networking design is left up to the reader but we do assume high availability.

Currently we support the following features:

1. Docker based deployment. The module installs docker on raw EC2 because that's the most predictable mechanism we've found so far. No binary installs here--it's all containerized.
2. Configurable number of workers and web nodes. Everything has a sane default but customize to your liking.
3. Requires AWS classic load balancing complete with SSL termination. Classic ELBs are required because we need the ability to service weird ports like 2222. ALBs support only HTTPS/HTTP and network LBs don't allow SSL termination.
4. Configurable authentication scheme (you need to know what you're doing though). Pass your secrets through the appropriate configuration variable and we'll pass that to the docker container.
5. Configurable cred store. Pass in your credential store switches through the appropriate variable and you'll be up and running in no time.

Most of what you need to know is provided in an example tfvars file, and feel free to peruse the `variables.tf` for documentation on the required variables to run the terraform.

For persistent storage we usually combine this module with an outer shell that provisiones an RDS PostgreSQL instance and we pass the credentials in securely. We do this because it allows us to segregate the RDS instance from concourse so if we need to blow away the concourse instance we can without worrying about having to reprovision a database.

This module should be fairly set-and-forget as we've put a lot of man hours into improving it. Feel free to hit us up via email or fork this repo and send PRs if you can think of a way to improve it!