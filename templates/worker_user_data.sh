#!bin/bash
sudo apt-get update
sudo unattended-upgrade -d

# Install interesting stuff.
sudo apt-get install -y apt-transport-https \
ca-certificates \
curl \
software-properties-common

sudo mkdir -p /etc/concourse/
sudo wget -P /etc/ https://github.com/concourse/concourse/releases/download/v${conc_version}/concourse-${conc_version}-linux-amd64.tgz
sudo tar -xzf /etc/concourse-${conc_version}-linux-amd64.tgz --directory=/etc/

sudo mkdir -p /etc/concourse/keys/worker
sudo mkdir -p /concourse-tmp
sudo chown -R ubuntu:ubuntu /etc/concourse
sudo chown -R ubuntu:ubuntu /concourse-tmp

# Dump keys into the correct place. Because terraform automatically
# adds a newline to any files read in we need to use echo -n here.
echo -n "${tsa_public_key}" > /etc/concourse/keys/worker/tsa_host_key.pub
echo -n "${worker_key}" > /etc/concourse/keys/worker/worker_key
sudo find /etc/concourse/keys/worker -type f -exec chmod 400 {} \;

echo /etc/concourse/bin/concourse worker \
--bind-ip 0.0.0.0 \
--baggageclaim-bind-ip 0.0.0.0 \
--tsa-host ${tsa_host}:2222 \
--tsa-public-key /etc/concourse/keys/worker/tsa_host_key.pub \
--tsa-worker-private-key /etc/concourse/keys/worker/worker_key \
--work-dir /concourse-tmp \
--garden-dns-proxy-enable \
${worker_launch_options}

/etc/concourse/bin/concourse worker \
--bind-ip 0.0.0.0 \
--baggageclaim-bind-ip 0.0.0.0 \
--garden-bind-ip 0.0.0.0 \
--peer-ip $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4) \
--tsa-host ${tsa_host}:2222 \
--tsa-public-key /etc/concourse/keys/worker/tsa_host_key.pub \
--tsa-worker-private-key /etc/concourse/keys/worker/worker_key \
--work-dir /concourse-tmp \
--garden-dns-proxy-enable \
${worker_launch_options}
