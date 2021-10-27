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
Environment=CONCOURSE_OIDC_USER_NAME_KEY=email

Type=simple
Restart=always
RestartSec=1
ExecStart=/etc/concourse/bin/concourse web \
--peer-address=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4) \
--postgres-host=${concdb_host} \
--postgres-port=${concdb_port} \
--postgres-user=${concdb_user} \
--postgres-password=${concdb_password} \
--postgres-database=${concdb_database} \
--external-url=https://${conc_fqdn} \
--container-placement-strategy=${container_placement_strategy} \
--session-signing-key=/etc/concourse/keys/web/session_signing_key \
--tsa-host-key=/etc/concourse/keys/web/tsa_host_key \
--tsa-authorized-keys=/etc/concourse/keys/web/authorized_worker_keys \
${authentication_config} \
${cred_store_config} \
${feature_flags}

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/concourse-web.service

systemctl start concourse-web