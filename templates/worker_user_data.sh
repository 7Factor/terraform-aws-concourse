#!/bin/bash
sudo apt-get update
sudo unattended-upgrade -d

# Install interesting stuff.
sudo apt-get install -y apt-transport-https \
ca-certificates \
software-properties-common

sudo mkdir -p /etc/concourse/
sudo wget -P /etc/ https://github.com/concourse/concourse/releases/download/v${conc_version}/concourse-${conc_version}-linux-amd64.tgz
sudo tar -xzf /etc/concourse-${conc_version}-linux-amd64.tgz --directory=/etc/

sudo mkdir -p /etc/concourse/keys/worker
sudo mkdir -p /concourse-tmp

# Dump keys into the correct place. Because terraform automatically
# adds a newline to any files read in we need to use echo -n here.
sudo echo -n "${tsa_public_key}" > /etc/concourse/keys/worker/tsa_host_key.pub
sudo echo -n "${worker_key}" > /etc/concourse/keys/worker/worker_key
sudo find /etc/concourse/keys/worker -type f -exec chmod 400 {} \;

sudo iptables -P FORWARD ACCEPT
sudo chown -R ubuntu:ubuntu /etc/concourse
sudo chown -R ubuntu:ubuntu /concourse-tmp

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
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
ExecStart=/etc/concourse/bin/concourse worker \
                --bind-ip 0.0.0.0 \
                --baggageclaim-bind-ip 0.0.0.0 \
                --garden-config /etc/concourse/gdn-config.ini
                --tsa-host ${tsa_host}:2222 \
                --tsa-public-key /etc/concourse/keys/worker/tsa_host_key.pub \
                --tsa-worker-private-key /etc/concourse/keys/worker/worker_key \
                --work-dir /concourse-tmp

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/concourse-worker.service

systemctl start concourse-worker