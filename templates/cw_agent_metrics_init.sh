#!/bin/bash
set -e

%{ if metrics_enabled }

echo 'Enabling CloudWatch EC2 metrics'

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a append-config \
  -m ec2 \
  -c file:/etc/cloudwatch/cw_metrics_config.json -s

%{ else }

echo 'CloudWatch EC2 metrics NOT enabled'

%{ endif }
