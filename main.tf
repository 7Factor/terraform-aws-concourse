# Required terraform version
terraform {
  required_version = ">=0.10.7"
}

# Grab the current region to be used everywhere
data "aws_region" "current" {}

#---------------------------------------------------------
# Concourse web server farm. We'll go with a passed in
# number of boxes and a load balancer.
#---------------------------------------------------------
data "aws_ami" "ecs_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

resource "aws_instance" "concourse_web" {
  count = "${var.web_count}"

  ami           = "${data.aws_ami.ecs_linux.id}"
  instance_type = "${var.web_instance_type}"
  subnet_id     = "${var.subnet_id}"
  key_name      = "${var.conc_ssh_key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.web_sg.id}",
    "${var.ssh_access}",
  ]

  tags {
    Name        = "concourse-web"
    Application = "concourse"
    Cluster     = "${var.cluster_name}"
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
      "sudo docker pull ${var.conc_image}",
      "sudo mv ~/keys /etc/concourse/",
      "docker run -d --name concourse_web -v /etc/concourse/keys/:/concourse-keys -p 8080:8080 -p 2222:2222 ${var.conc_image} web --postgres-data-source ${var.postgres_connection} --external-url ${var.fqdn} ${var.authentication_config}"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("${path.root}/keys/${var.conc_ssh_key_name}.pem")}"
    }
  }
}

resource "aws_elb" "concourse_lb" {
  name    = "conc-lb-${data.aws_region.current.name}"
  subnets = ["${var.subnet_id}"]

  security_groups = [
    "${aws_security_group.httplb_sg.id}",
  ]

  instances = ["${aws_instance.concourse_web.*.id}"]

  listener {
    instance_port      = 8080
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${var.web_cert_arn}"
  }

  # For external workers
  listener {
    instance_port     = 2222
    instance_protocol = "tcp"
    lb_port           = 2222
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/"
    interval            = 30
  }

  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name        = "concourse-lb"
    Application = "concourse"
    Cluster     = "${var.cluster_name}"
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
  subnet_id     = "${var.subnet_id}"
  key_name      = "${var.conc_ssh_key_name}"

  vpc_security_group_ids = [
    "${var.ssh_access}",
    "${aws_security_group.worker_sg.id}",
  ]

  tags {
    Name        = "concourse-worker"
    Application = "concourse"
    Cluster     = "${var.cluster_name}"
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
