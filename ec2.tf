resource "aws_instance" "concourse_web" {
  count = "${var.web_count}"

  ami           = "${data.aws_ami.ecs_linux.id}"
  instance_type = "${var.web_instance_type}"

  # We're doing some magic here to allow for any number of count that's evenly distributed
  # across the configured subnets.
  subnet_id = "${var.web_public_subnets[count.index % length(var.web_public_subnets)]}"

  key_name = "${var.conc_ssh_key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.web_sg.id}",
    "${var.bastion_access_sg}",
  ]

  tags {
    Name    = "Concourse Web"
    Cluster = "${var.cluster_name}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/concourse/keys",
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
      "sleep 5",
      "sudo docker pull ${var.conc_image}",
      "sudo mv ~/keys /etc/concourse/",
      "docker run -d --name concourse_web -v /etc/concourse/keys/:/concourse-keys -p 8080:8080 -p 2222:2222 ${var.conc_image} web --postgres-data-source ${var.postgres_connection} --external-url ${var.fqdn} ${var.authentication_config}",
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

  ami           = "${data.aws_ami.ecs_linux.id}"
  instance_type = "${var.worker_instance_type}"

  # We're doing some magic here to allow for any number of count that's evenly distributed
  # across the configured subnets.
  subnet_id = "${var.worker_subnets[count.index % length(var.worker_subnets)]}"

  key_name = "${var.conc_ssh_key_name}"

  vpc_security_group_ids = [
    "${var.bastion_access_sg}",
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
      "sleep 5",
      "sudo docker pull ${var.conc_image}",
      "sudo mv ~/keys /etc/concourse/",
      "sudo docker run -d --name concourse_worker --privileged=true -v /etc/concourse/keys/:/concourse-keys -v /tmp/:/concourse-tmp -p 2222:2222 -p 7777:7777 -p 7788:7788 ${var.conc_image} worker --tsa-host ${aws_elb.concourse_lb.dns_name} --work-dir /concourse-tmp",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("${path.root}/keys/${var.conc_ssh_key_name}.pem")}"
    }
  }
}
