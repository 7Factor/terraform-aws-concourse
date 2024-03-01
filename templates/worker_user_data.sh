#!/bin/bash
sudo mkdir -p /etc/concourse/ /etc/concourse/keys/worker /opt/concourse-workdir /etc/concourse
sudo curl -o /etc/concourse.tgz -L https://github.com/concourse/concourse/releases/download/v${conc_version}/concourse-${conc_version}-linux-amd64.tgz
sudo tar -xzf /etc/concourse.tgz --directory=/etc/

# Dump keys into the correct place. Because terraform automatically
# adds a newline to any files read in we need to use echo -n here.
sudo echo -n "${tsa_public_key}" > /etc/concourse/keys/worker/tsa_host_key.pub
sudo echo -n "${worker_key}" > /etc/concourse/keys/worker/worker_key
sudo find /etc/concourse/keys/worker -type f -exec chmod 400 {} \;

sudo echo "
[Unit]
Description=Concourse Worker Service
After=network.target

[Service]
Environment=\"CONCOURSE_BIND_IP=0.0.0.0\"
Environment=\"CONCOURSE_BAGGAGECLAIM_BIND_IP=0.0.0.0\"
Environment=\"CONCOURSE_BAGGAGECLAIM_DRIVER=${storage_driver}\"
Environment=\"CONCOURSE_TSA_HOST=${tsa_host}:2222\"
Environment=\"CONCOURSE_TSA_PUBLIC_KEY=/etc/concourse/keys/worker/tsa_host_key.pub\"
Environment=\"CONCOURSE_TSA_WORKER_PRIVATE_KEY=/etc/concourse/keys/worker/worker_key\"
Environment=\"CONCOURSE_WORK_DIR=/opt/concourse-workdir\"
Environment=\"CONCOURSE_GARDEN_DNS_SERVER=${join(",", dns_servers)}\"

%{ for item in feature_flags ~}
Environment=\"${item}\"
%{ endfor ~}

Type=simple
Restart=always
RestartSec=1
ExecStart=/etc/concourse/bin/concourse worker

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/concourse-worker.service

systemctl enable concourse-worker
systemctl start concourse-worker

sudo echo "
[Unit]
Description=Deregister worker on shutdown
Before=shutdown.target halt.target
Requires=network-online.target network.target

[Service]
Environment=\"CONCOURSE_TSA_HOST=${tsa_host}:2222\"
Environment=\"CONCOURSE_TSA_PUBLIC_KEY=/etc/concourse/keys/worker/tsa_host_key.pub\"
Environment=\"CONCOURSE_TSA_WORKER_PRIVATE_KEY=/etc/concourse/keys/worker/worker_key\"

KillMode=none
ExecStart=/bin/true
ExecStop=/etc/concourse/bin/concourse retire-worker --name $(hostname)
RemainAfterExit=yes
Type=oneshot

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/concourse-deregister-worker.service

systemctl enable concourse-deregister-worker
systemctl start concourse-deregister-worker
