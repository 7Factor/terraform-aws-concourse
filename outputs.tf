output "lb_dns" {
  value       = "${aws_elb.concourse_lb.dns_name}"
  description = "The DNS value of your LB hosting the concourse cluster. Point your FQDN to it."
}

output "web_sg_id" {
  value       = "${aws_security_group.web_sg.id}"
  description = "Security group for web boxes. Consume this by other modules as necessary--specifically locking down DB access."
}

output "web_asg_id" {
  value       = "${aws_autoscaling_group.web_asg.id}"
  description = "ID of the web ASG so you can attach your own scaling policies."
}
