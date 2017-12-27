output "lb_dns" {
  value = "${aws_elb.concourse_lb.dns_name}"
}
