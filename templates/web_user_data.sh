#!/bin/bash
sudo apt-get update
sudo unattended-upgrade -d

sudo mkdir -p /etc/concourse/
sudo curl -o /etc/concourse.tgz -L https://github.com/concourse/concourse/releases/download/v${conc_version}/concourse-${conc_version}-linux-amd64.tgz
sudo tar -xzf /etc/concourse.tgz --directory=/etc/

sudo mkdir -p /etc/concourse/keys/web

# Dump keys into the correct place. Because terraform automatically
# adds a newline to any files read in we need to use echo -n here.
sudo echo -n "${authorized_worker_keys}" > /etc/concourse/keys/web/authorized_worker_keys
sudo echo -n "${session_signing_key}" > /etc/concourse/keys/web/session_signing_key
sudo echo -n "${tsa_host_key}" > /etc/concourse/keys/web/tsa_host_key
sudo find /etc/concourse/keys/web -type f -exec chmod 400 {} \;

sudo chown -R root:root /etc/concourse

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
