#!/bin/bash
sudo apt-get update
sudo unattended-upgrade -d

sudo mkdir -p /etc/concourse/
sudo curl -o /etc/concourse.tgz -L https://github.com/concourse/concourse/releases/download/v${conc_version}/concourse-${conc_version}-linux-amd64.tgz
sudo tar -xzf /etc/concourse.tgz --directory=/etc/

sudo mkdir -p /etc/concourse/keys/worker
sudo mkdir -p /concourse-tmp

# Dump keys into the correct place. Because terraform automatically
# adds a newline to any files read in we need to use echo -n here.
sudo echo -n "${tsa_public_key}" > /etc/concourse/keys/worker/tsa_host_key.pub
sudo echo -n "${worker_key}" > /etc/concourse/keys/worker/worker_key
sudo find /etc/concourse/keys/worker -type f -exec chmod 400 {} \;

sudo chown -R root:root /etc/concourse
sudo chown -R root:root /concourse-tmp

sudo echo "
[server]
; configure Google DNS
dns-server = 8.8.8.8
dns-server = 8.8.4.4
" > /etc/concourse/gdn-config.ini

sudo echo "
[Unit]
Description=Concourse Worker Service
After=network.target

[Service]
Environment=\"CONCOURSE_BIND_IP=0.0.0.0\"
Environment=\"CONCOURSE_BAGGAGECLAIM_BIND_IP=0.0.0.0\"
Environment=\"CONCOURSE_GARDEN_CONFIG=/etc/concourse/gdn-config.ini\"
Environment=\"CONCOURSE_BAGGAGECLAIM_DRIVER=${baggageclaim_driver}\"
Environment=\"CONCOURSE_TSA_HOST=${tsa_host}:2222\"
Environment=\"CONCOURSE_TSA_PUBLIC_KEY=/etc/concourse/keys/worker/tsa_host_key.pub\"
Environment=\"CONCOURSE_TSA_WORKER_PRIVATE_KEY=/etc/concourse/keys/worker/worker_key\"
Environment=\"CONCOURSE_WORK_DIR=/concourse-tmp\"

Type=simple
Restart=always
RestartSec=1
ExecStart=/etc/concourse/bin/concourse worker

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/concourse-worker.service

systemctl enable concourse-worker
systemctl start concourse-worker
