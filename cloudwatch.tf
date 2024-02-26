resource "aws_cloudwatch_log_group" "concourse" {
  name = var.prometheus_log_group_name
}
