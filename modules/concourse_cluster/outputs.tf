output "db_ip" {
  value = "${aws_instance.concourse_db.public_ip}"
}

output "lb_url" {
  value = "${aws_elb.concourse_lb.public_dns}"
}
