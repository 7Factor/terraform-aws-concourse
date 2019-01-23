#!bin/bash
sudo apt-get update
sudo unattended-upgrade -d
sudo apt-get remove docker docker-engine docker.io

# Install interesting stuff.
sudo apt-get install -y apt-transport-https \
ca-certificates \
curl \
software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce
sudo usermod -aG docker ubuntu

sudo mkdir -p /etc/concourse/keys/worker
sudo chown -R ubuntu:ubuntu /etc/concourse

# Dump keys into the correct place.
printf "${tsa_public_key}" > /etc/concourse/keys/worker/tsa_host_key.pub
printf "${worker_key}" > /etc/concourse/keys/worker/worker_key
find /etc/concourse/keys/worker -type f -exec chmod 400 {} \\;

# Pull the image
docker pull ${conc_image}

sudo docker run -d --name concourse_worker --privileged=true \
--restart=unless-stopped \
-h $(curl -s http://169.254.169.254/latest/meta-data/hostname) \
-v /etc/concourse/keys/worker:/concourse-keys \
-v /tmp/:/concourse-tmp \
-p 7777:7777 -p 7788:7788 -p 7799:7799 \
${conc_image} worker \
--bind-ip 0.0.0.0 \
--baggageclaim-bind-ip 0.0.0.0 \
--garden-bind-ip 0.0.0.0 \
--peer-ip $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4) \
--tsa-host ${tsa_host}:2222 \
--work-dir /concourse-tmp \
--garden-dns-proxy-enable \
${worker_launch_options}
