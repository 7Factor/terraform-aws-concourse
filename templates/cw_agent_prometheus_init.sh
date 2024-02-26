#!/bin/bash
set -e

%{ if prometheus_enabled }

echo 'Enabling CloudWatch Prometheus metrics'

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a append-config \
  -m ec2 \
  -c file:/etc/cloudwatch/cw_prometheus_config.json -s

%{ else }

echo 'CloudWatch Prometheus metrics NOT enabled'

%{ endif }
