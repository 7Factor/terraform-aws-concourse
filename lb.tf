resource "aws_elb" "concourse_lb" {
  name    = "conc-lb"
  subnets = flatten([var.web_public_subnets])

  security_groups = [
    aws_security_group.httplb_sg.id,
  ]

  internal = var.lb_internal

  listener {
    instance_port      = 8080
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = var.web_cert_arn
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

  tags = {
    Name = "Concourse LB"
  }
}
