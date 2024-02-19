#!/bin/bash
set -e

# Output all logs
exec > >(tee /var/log/user-data.log|logger -t user-data-extra -s 2>/dev/console) 2>&1

# Make sure we have the latest packages
sudo yum update -y
sudo yum upgrade -y

echo 'Configuring CloudWatch agent'

# Install CloudWatch agent
sudo yum install -y amazon-cloudwatch-agent

# Use CloudWatch config from SSM
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c ssm:${ssm_cloudwatch_config} -s

echo 'Configuring Concourse'

sudo mkdir -p /etc/concourse/ /etc/concourse/keys/web
sudo curl -o /etc/concourse.tgz -L https://github.com/concourse/concourse/releases/download/v${conc_version}/concourse-${conc_version}-linux-amd64.tgz
sudo tar -xzf /etc/concourse.tgz --directory=/etc/

# Dump keys into the correct place. Because terraform automatically
# adds a newline to any files read in we need to use echo -n here.
sudo echo -n "${authorized_worker_keys}" > /etc/concourse/keys/web/authorized_worker_keys
sudo echo -n "${session_signing_key}" > /etc/concourse/keys/web/session_signing_key
sudo echo -n "${tsa_host_key}" > /etc/concourse/keys/web/tsa_host_key
sudo find /etc/concourse/keys/web -type f -exec chmod 400 {} \;

sudo echo "${concourse_base_resource_type_defaults}" > /etc/concourse/base_resource_type_defaults.yml
sudo chmod 644 /etc/concourse/base_resource_type_defaults.yml

sudo echo "
[Unit]
Description=Concourse Web Service
After=network.target

[Service]
Environment=\"CONCOURSE_PEER_ADDRESS=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)\"
Environment=\"CONCOURSE_POSTGRES_HOST=${concdb_host}\"
Environment=\"CONCOURSE_POSTGRES_PORT=${concdb_port}\"
Environment=\"CONCOURSE_POSTGRES_USER=${concdb_user}\"
Environment=\"CONCOURSE_POSTGRES_PASSWORD=${concdb_password}\"
Environment=\"CONCOURSE_POSTGRES_DATABASE=${concdb_database}\"
Environment=\"CONCOURSE_EXTERNAL_URL=https://${conc_fqdn}\"
Environment=\"CONCOURSE_CONTAINER_PLACEMENT_STRATEGY=${container_placement_strategy}\"
Environment=\"CONCOURSE_SESSION_SIGNING_KEY=/etc/concourse/keys/web/session_signing_key\"
Environment=\"CONCOURSE_TSA_HOST_KEY=/etc/concourse/keys/web/tsa_host_key\"
Environment=\"CONCOURSE_TSA_AUTHORIZED_KEYS=/etc/concourse/keys/web/authorized_worker_keys\"
Environment=\"CONCOURSE_BASE_RESOURCE_TYPE_DEFAULTS=/etc/concourse/base_resource_type_defaults.yml\"

%{ for item in authentication_config ~}
Environment=\"${item}\"
%{ endfor ~}

%{ for item in cred_store_config ~}
Environment=\"${item}\"
%{ endfor ~}

%{ for item in feature_flags ~}
Environment=\"${item}\"
%{ endfor ~}

Type=simple
Restart=always
RestartSec=1
ExecStart=/etc/concourse/bin/concourse web

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/concourse-web.service

systemctl enable concourse-web
systemctl start concourse-web

echo 'Initialization complete'
