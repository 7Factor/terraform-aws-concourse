#---------------------------------------------------------
# SGs for access to concourse servers. One for the web farm
# and another for SSH access and another for DB access.
#---------------------------------------------------------
resource "aws_security_group" "web_sg" {
  name        = "conc-web-sg-${data.aws_region.current.name}"
  description = "Security group for all concourse web servers in ${data.aws_region.current.name}."
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = ["${aws_security_group.httplb_sg.id}"]
  }

  ingress {
    from_port       = 2222
    to_port         = 2222
    protocol        = "tcp"
    security_groups = ["${aws_security_group.httplb_sg.id}"]
  }

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name    = "Concourse Web Boxes"
    Cluster = "${var.cluster_name}"
  }
}

resource "aws_security_group_rule" "allow_worker_to_register" {
  type                     = "ingress"
  from_port                = 2222
  to_port                  = 2222
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.worker_sg.id}"
  security_group_id        = "${aws_security_group.web_sg.id}"

  depends_on = ["aws_security_group.worker_sg", "aws_security_group.web_sg"]
}

resource "aws_security_group_rule" "allow_worker_to_web" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.worker_sg.id}"
  security_group_id        = "${aws_security_group.web_sg.id}"

  depends_on = ["aws_security_group.worker_sg", "aws_security_group.web_sg"]
}

resource "aws_security_group" "worker_sg" {
  name        = "conc-worker-sg-${data.aws_region.current.name}"
  description = "Opens all the appropriate concourse worker ports in ${data.aws_region.current.name}"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 7777
    to_port         = 7777
    protocol        = "tcp"
    security_groups = ["${aws_security_group.web_sg.id}"]
  }

  ingress {
    from_port       = 7788
    to_port         = 7788
    protocol        = "tcp"
    security_groups = ["${aws_security_group.web_sg.id}"]
  }

  ingress {
    from_port       = 7799
    to_port         = 7799
    protocol        = "tcp"
    security_groups = ["${aws_security_group.web_sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name    = "Concourse Worker Boxes"
    Cluster = "${var.cluster_name}"
  }
}

resource "aws_security_group" "httplb_sg" {
  name        = "conc-lb-sg-${data.aws_region.current.name}"
  description = "Security group for the LB in ${data.aws_region.current.name}."
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.web_ingress_cidr}"]
  }

  # For external worker registration
  ingress {
    from_port   = 2222
    to_port     = 2222
    protocol    = "tcp"
    cidr_blocks = ["${var.web_ingress_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name    = "Concourse Load Balancer"
    Cluster = "${var.cluster_name}"
  }
}
