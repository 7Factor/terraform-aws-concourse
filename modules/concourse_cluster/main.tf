# Required terraform version
terraform {
  required_version = ">=0.10.7"
}

#---------------------------------------------------------
# SGs for access to concourse servers. One for the web farm
# and another for SSH access and another for DB access.
#---------------------------------------------------------
resource "aws_security_group" "conc_web_sg" {
  name        = "conc-web-sg-${var.region}"
  description = "Security group for all concourse web servers in ${var.region}."
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${var.conc_web_ingress_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Application = "concourse"
    Cluster     = "${var.cluster_name}"
  }
}

resource "aws_security_group" "conc_tsa_sg" {
  name        = "conc-web-sg-${var.region}"
  description = "Security group for all TSA access in ${var.region}."
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 2222
    to_port     = 2222
    protocol    = "tcp"
    cidr_blocks = ["${var.conc_tsa_ingress_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Application = "concourse"
    Cluster     = "${var.cluster_name}"
  }
}

resource "aws_security_group" "conc_ssh_access" {
  name        = "conc-ssh-sg-${var.region}"
  description = "Opens SSH to concourse servers in ${var.region}"
  vpc_id      = "${var.vpc_id}"

  // Assumes default ports
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.conc_ssh_ingress_cidr}"]
  }

  // Per docs, this means allow all leaving.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Application = "concourse"
    Cluster     = "${var.cluster_name}"
  }
}

resource "aws_security_group" "conc_db_sg" {
  name        = "conc-db-sg-${var.region}"
  description = "Security group for all concourse DB servers in ${var.region}."
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Application = "concourse"
    Cluster     = "${var.cluster_name}"
  }
}

resource "aws_security_group" "conc_httplb_sg" {
  name        = "conc-lb-sg-${var.region}"
  description = "Security group for the LB in ${var.region}."
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.conc_web_ingress_cidr}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.conc_web_ingress_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Application = "concourse"
    Cluster     = "${var.cluster_name}"
  }
}

#---------------------------------------------------------
# PostGRES EC2 instance for concourse DB. There's no good
# reason to run this in RDS unless you're build farm is
# so large it needs a cluster.
#---------------------------------------------------------
data "aws_ami" "ec2_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-x86_64-gp2"]
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

resource "aws_instance" "concourse_db" {
  ami           = "${data.aws_ami.ec2_linux.id}"
  instance_type = "${var.conc_db_instance_type}"
  subnet_id     = "${var.subnet_id}"
  key_name      = "${var.conc_ssh_key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.conc_db_sg.id}",
    "${aws_security_group.conc_ssh_access.id}",
  ]

  tags {
    Name        = "concourse-postgres"
    Application = "concourse"
    Cluster     = "${var.cluster_name}"
  }

  provisioner "file" {
    source      = "${path.module}/conf/pg_hba.conf"
    destination = "/tmp/pg_hba.conf"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("${path.root}/keys/${var.conc_ssh_key_name}.pem")}"
    }
  }

  provisioner "file" {
    source      = "${path.module}/conf/postgresql.conf"
    destination = "/tmp/postgresql.conf"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("${path.root}/keys/${var.conc_ssh_key_name}.pem")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum -y install postgresql96 postgresql96-server postgresql96-devel postgresql96-contrib postgresql96-docs",
      "sudo service postgresql96 initdb",
      "sudo cp /tmp/postgresql.conf /var/lib/pgsql96/data/postgresql.conf",
      "sudo cp /tmp/pg_hba.conf /var/lib/pgsql96/data/pg_hba.conf",
      "sudo service postgresql96 start",
      "sudo -u postgres psql -c \"CREATE USER concourse SUPERUSER; ALTER USER concourse WITH PASSWORD '${var.conc_db_pw}';\"",
      "sudo -u postgres createdb concourse -O concourse",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("${path.root}/keys/${var.conc_ssh_key_name}.pem")}"
    }
  }
}

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
  count      = "${var.conc_web_count}"
  depends_on = ["aws_instance.concourse_db"]

  ami           = "${data.aws_ami.ecs_linux.id}"
  instance_type = "${var.conc_web_instance_type}"
  subnet_id     = "${var.subnet_id}"
  key_name      = "${var.conc_ssh_key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.conc_web_sg.id}",
    "${aws_security_group.conc_ssh_access.id}",
    "${aws_security_group.conc_tsa_sg.id}",
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
    source      = "${var.conc_web_keys_dir}"
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
      "sudo docker pull concourse/concourse",
      "sudo mv ~/keys /etc/concourse/",
      "docker run -d -v /etc/concourse/keys/:/concourse-keys -p 8080:8080 concourse/concourse web --postgres-data-source postgres://concourse:${var.conc_db_pw}@${aws_instance.concourse_db.public_ip}?sslmode=disable --external-url ${var.conc_fqdn} --no-really-i-dont-want-any-auth",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("${path.root}/keys/${var.conc_ssh_key_name}.pem")}"
    }
  }
}

resource "aws_elb" "concourse_lb" {
  name    = "conc-lb-${var.region}"
  subnets = ["${var.subnet_id}"]

  security_groups = [
    "${aws_security_group.conc_httplb_sg.id}",
    "${aws_security_group.conc_tsa_sg.id}",
  ]

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/"
    interval            = 30
  }

  instances                   = ["${aws_instance.concourse_web.*.id}"]
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
  count      = "${var.conc_worker_count}"
  depends_on = ["aws_instance.concourse_web"]

  ami           = "${data.aws_ami.ecs_linux.id}"
  instance_type = "${var.conc_worker_instance_type}"
  subnet_id     = "${var.subnet_id}"
  key_name      = "${var.conc_ssh_key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.conc_tsa_sg.id}",
    "${aws_security_group.conc_ssh_access.id}",
  ]

  tags {
    Name        = "concourse-wrk"
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
    source      = "${var.conc_web_keys_dir}"
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
      "sudo docker pull concourse/concourse",
      "sudo mv ~/keys /etc/concourse/",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("${path.root}/keys/${var.conc_ssh_key_name}.pem")}"
    }
  }
}
