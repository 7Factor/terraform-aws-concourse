resource "aws_instance" "concourse_web" {
  count = "${var.web_count}"

  ami           = "${data.aws_ami.aws_linux.id}"
  instance_type = "${var.web_instance_type}"

  # We're doing some magic here to allow for any number of count that's evenly distributed
  # across the configured subnets.
  subnet_id = "${var.web_private_subnets[count.index % length(var.web_private_subnets)]}"

  key_name = "${var.conc_ssh_key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.web_sg.id}",
    "${var.utility_accessible_sg}",
  ]

  tags {
    Name    = "Concourse Web"
    Cluster = "${var.cluster_name}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/concourse/keys",
      "sudo chown -R ec2-user:ec2-user /etc/concourse",
      "mkdir -p ~/keys",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("${path.root}/keys/${var.conc_ssh_key_name}.pem")}"
    }
  }

  provisioner "file" {
    source      = "${var.web_keys_dir}"
    destination = "~/keys/"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("${path.root}/keys/${var.conc_ssh_key_name}.pem")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum -y install docker",
      "sudo service docker start",
      "sudo usermod -aG docker ec2-user",
      "sudo docker pull ${var.conc_image}",
      "sudo mv ~/keys /etc/concourse/",
      "sudo find /etc/concourse/keys/ -type f -exec chmod 400 {} \\;",
      "sudo docker run -d --name concourse_web --restart=unless-stopped -v /etc/concourse/keys/:/concourse-keys -p 8080:8080 -p 2222:2222 ${var.conc_image} web --peer-url http://${self.private_ip}:8080 --postgres-data-source ${var.postgres_connection} --log-level debug --external-url ${var.fqdn} ${var.authentication_config}",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("${path.root}/keys/${var.conc_ssh_key_name}.pem")}"
    }
  }
}

#---------------------------------------------------------
# Concourse worker farm.
#---------------------------------------------------------
resource "aws_instance" "concourse_worker" {
  count      = "${var.worker_count}"
  depends_on = ["aws_elb.concourse_lb"]

  ami           = "${data.aws_ami.aws_linux.id}"
  instance_type = "${var.worker_instance_type}"

  # We're doing some magic here to allow for any number of count that's evenly distributed
  # across the configured subnets.
  subnet_id = "${var.worker_subnets[count.index % length(var.worker_subnets)]}"

  key_name = "${var.conc_ssh_key_name}"

  vpc_security_group_ids = [
    "${var.utility_accessible_sg}",
    "${aws_security_group.worker_sg.id}",
  ]

  tags {
    Name    = "Concourse Worker"
    Cluster = "${var.cluster_name}"
  }

  root_block_device {
    volume_size = "${var.worker_vol_size}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/concourse/keys",
      "sudo chown -R ec2-user:ec2-user /etc/concourse",
      "mkdir -p ~/keys",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("${path.root}/keys/${var.conc_ssh_key_name}.pem")}"
    }
  }

  provisioner "file" {
    source      = "${var.worker_keys_dir}"
    destination = "~/keys/"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("${path.root}/keys/${var.conc_ssh_key_name}.pem")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum -y install docker",
      "sudo service docker start",
      "sudo usermod -aG docker ec2-user",
      "sudo docker pull ${var.conc_image}",
      "sudo mv ~/keys /etc/concourse/",
      "sudo find /etc/concourse/keys/ -type f -exec chmod 400 {} \\;",
      "sudo docker run -d --name concourse_worker --privileged=true --restart=unless-stopped -p 7788:7788 -p 7777:7777 -p 7799:7799 -v /etc/concourse/keys/:/concourse-keys -v /tmp/:/concourse-tmp ${var.conc_image} worker --peer-ip ${self.private_ip} --bind-ip 0.0.0.0 --log-level debug --tsa-host ${aws_elb.concourse_lb.dns_name}:2222 --work-dir /concourse-tmp",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("${path.root}/keys/${var.conc_ssh_key_name}.pem")}"
    }
  }
}
