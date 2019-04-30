#!/bin/bash
sudo apt-get update
sudo unattended-upgrade -d

sudo mkdir -p /etc/concourse/
sudo curl -o /etc/concourse.tgz https://github.com/concourse/concourse/releases/download/v${conc_version}/concourse-${conc_version}-linux-amd64.tgz
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
StartLimitInterval=0

[Service]
Type=simple
Restart=always
RestartSec=1
ExecStart=/etc/concourse/bin/concourse worker \
                --bind-ip 0.0.0.0 \
                --baggageclaim-bind-ip 0.0.0.0 \
                --garden-config /etc/concourse/gdn-config.ini \
                --baggageclaim-driver ${baggageclaim_driver} \
                --tsa-host ${tsa_host}:2222 \
                --tsa-public-key /etc/concourse/keys/worker/tsa_host_key.pub \
                --tsa-worker-private-key /etc/concourse/keys/worker/worker_key \
                --work-dir /concourse-tmp

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/concourse-worker.service

systemctl start concourse-worker