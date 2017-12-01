# Concourse on AWS via Terraform

[![Waffle.io - Columns and their card count](https://badge.waffle.io/7Factor/7fpub-aws-concourse.svg?columns=all)](https://waffle.io/7Factor/7fpub-aws-concourse)

This module will allow you to publish concourse on your own AWS infrastructure. Currently it supports the following features:

1. Docker based deployment. The module uses the most recent ECS AMI for deployment.
2. Configurable number of workers and webs along with volume sizes and instance types.
3. Supports AWS application load balancing complete with SSL termination.
4. Support for GitHub authentication (you can fork and remove if you want to use something else).
5. Configurable PostGres installation because you don't need RDS for this. It's way cheaper.

More to come on how to use it!