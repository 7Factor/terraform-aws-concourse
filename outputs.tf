output "lb_dns" {
  value       = aws_elb.concourse_lb.dns_name
  description = "The DNS value of your LB hosting the concourse cluster. Point your FQDN to it."
}

output "lb_zone_id" {
  value       = aws_elb.concourse_lb.zone_id
  description = "The zone ID of your LB hosting the concourse cluster."
}

output "web_sg" {
  value       = aws_security_group.web_sg.id
  description = "ID of the security group for web boxes. Consume this by other modules as necessary--specifically locking down DB access."
}

output "web_asg_name" {
  value       = aws_autoscaling_group.web_asg.name
  description = "Name of the web ASG so you can attach your own scaling policies."
}

output "worker_asg_name" {
  value       = aws_autoscaling_group.worker_asg.id
  description = "Name of the worker ASG so you can attach your own scaling policies."
}

output "utility_accessible_sg" {
  value       = var.utility_accessible_sg
  description = "Utility accessible SG for consumption by other terraform."
}

output "vpc_id" {
  value       = var.vpc_id
  description = "The VPC id that concourse was installed in for consumption by other terraform."
}
