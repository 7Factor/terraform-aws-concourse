resource "aws_security_group" "web_sg" {
  name        = "conc-web-sg"
  description = "Security group for all concourse web servers."
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.httplb_sg.id]
  }

  ingress {
    from_port       = 2222
    to_port         = 2222
    protocol        = "tcp"
    security_groups = [aws_security_group.httplb_sg.id]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Concourse Web Boxes"
  }
}

resource "aws_security_group" "allow_workers_to_web" {
  name        = "conc-worker-to-web"
  description = "Allows workers to register and contact web machines. Assign to web boxes."
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 2222
    to_port         = 2222
    protocol        = "tcp"
    security_groups = [aws_security_group.worker_sg.id]
  }

  tags = {
    Name = "Workers Access Web Boxes"
  }

  depends_on = ["aws_security_group.worker_sg", "aws_security_group.web_sg"]
}

resource "aws_security_group" "worker_sg" {
  name        = "conc-worker-sg"
  description = "Opens all the appropriate concourse worker ports to web nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 7777
    to_port         = 7777
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  ingress {
    from_port       = 7788
    to_port         = 7788
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  ingress {
    from_port       = 7799
    to_port         = 7799
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Concourse Worker Boxes"
  }
}

resource "aws_security_group" "httplb_sg" {
  name        = "conc-lb-sg"
  description = "Security group for the concourse ELB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.web_ingress_cidr]
  }

  # For external worker registration
  ingress {
    from_port   = 2222
    to_port     = 2222
    protocol    = "tcp"
    cidr_blocks = [var.web_ingress_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Concourse Load Balancer"
  }
}
