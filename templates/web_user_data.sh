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

sudo mkdir -p /etc/concourse/keys/web
sudo chown -R ubuntu:ubuntu /etc/concourse

# Dump keys into the correct place.
echo "${authorized_worker_keys}" >> /etc/concourse/keys/web/authorized_workers
echo "${session_signing_key}" >> /etc/concourse/keys/web/session_signing_key
echo "${tsa_host_key}" >> /etc/concourse/keys/web/tsa_host_key
find /etc/concourse/keys/web -type f -exec chmod 400 {} \\;

# Pull the image
docker pull ${conc_image}

docker run -d --name concourse_web --restart=unless-stopped \
-h $(curl -s http://169.254.169.254/latest/meta-data/hostname) \
-v /etc/concourse/keys/:/concourse-keys \
-p 8080:8080 -p 2222:2222 \
${conc_image} web \
--peer-url http://$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4):8080 \
--postgres-host ${concdb_host} \
--postgres-port ${concdb_port} \
--postgres-user ${concdb_user} \
--postgres-password ${concdb_password} \
--postgres-database ${concdb_database} \
--external-url https://${conc_fqdn} \
${authentication_config} \
${cred_store_config} \
${web_launch_options}

