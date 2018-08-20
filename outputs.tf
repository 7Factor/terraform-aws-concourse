output "lb_dns" {
  value       = "${aws_elb.concourse_lb.dns_name}"
  description = "The DNS value of your LB hosting the concourse cluster. Point your FQDN to it."
}
