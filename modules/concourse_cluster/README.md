# Concourse Cluster

This module will allow you to easitly deploy a cluster of concourse servers to your AWS infrastructure.

## What do you need

This module will root the cluster in a VPC and subnet of your choosing. We do this because we expect most folks will build out the network aside from the build cluster. Make sure you have the following:

1. A PEM key for access to all the boxes. For ease of use we supply a single key for all concourse resources.
1. A VPC and subnet ID to root the cluster in.
1. Keys generated for concourse workers and web instances per concourse documentation.
1. An SSL cert defined in the AWS certificate manager. You'll pass the ARN into the module which will configure the load balancer for SSL termination.