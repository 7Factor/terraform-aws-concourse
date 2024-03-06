#!/bin/bash
set -e

%{ if prometheus_enabled || metrics_enabled }

echo 'Configuring CloudWatch agent'

sudo mkdir -p /etc/cloudwatch
echo -n '${cw_agent_config}' > /etc/cloudwatch/cw_agent_config.json
echo -n '${cw_metrics_config}' > /etc/cloudwatch/cw_metrics_config.json
echo -n '${cw_prometheus_config}' > /etc/cloudwatch/cw_prometheus_config.json

sudo mkdir -p /etc/prometheus
echo -n '${prometheus_config}' > /etc/prometheus/config.yml

sudo yum install -y amazon-cloudwatch-agent

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/etc/cloudwatch/cw_agent_config.json -s

%{ else }

echo 'CloudWatch agent NOT enabled'

%{ endif }
