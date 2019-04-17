#!bin/bash
sudo apt-get update
sudo unattended-upgrade -d

# Install interesting stuff.
sudo apt-get install -y apt-transport-https \
ca-certificates \
curl \
software-properties-common

sudo mkdir -p /etc/concourse/
sudo curl https://github.com/concourse/concourse/releases/download/v${conc_version}/concourse-${conc_version}-linux-amd64.tgz
tar -xzf concourse-${conc_version}-linux-amd64.tgz /etc/

sudo mkdir -p /etc/concourse/keys/web
sudo chown -R ubuntu:ubuntu /etc/concourse

# Dump keys into the correct place. Because terraform automatically
# adds a newline to any files read in we need to use echo -n here.
echo -n "${authorized_worker_keys}" > /etc/concourse/keys/web/authorized_worker_keys
echo -n "${session_signing_key}" > /etc/concourse/keys/web/session_signing_key
echo -n "${tsa_host_key}" > /etc/concourse/keys/web/tsa_host_key
find /etc/concourse/keys/web -type f -exec chmod 400 {} \\;

curl https://github.com/concourse/concourse/releases/download/v${conc_version}/concourse-${conc_version}-linux-amd64.tgz
tar -xzf concourse-${conc_version}-linux-amd64.tgz /etc/

/etc/concourse/bin/concourse web \
--peer-address http://$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4):8080 \
--postgres-host ${concdb_host} \
--postgres-port ${concdb_port} \
--postgres-user ${concdb_user} \
--postgres-password ${concdb_password} \
--postgres-database ${concdb_database} \
--external-url https://${conc_fqdn} \
--tsa-session-signing-key /etc/concourse/keys/web/session_signing_key \
--tsa-host-key /etc/concourse/keys/web/tsa_host_key \
--tsa-authorized-keys /etc/concourse/keys/web/authorized_worker_keys \
${authentication_config} \
${cred_store_config} \
${web_launch_options}

