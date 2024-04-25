locals {
  web_user_data_content    = sensitive(templatefile("${path.module}/templates/web_user_data.sh", local.web_interpolation_vars))
  worker_user_data_content = sensitive(templatefile("${path.module}/templates/worker_user_data.sh", local.worker_interpolation_vars))
}

resource "aws_s3_bucket" "user_data" {
  bucket = var.user_data_bucket_name
}

resource "aws_s3_bucket_ownership_controls" "user_data_ownership" {
  bucket = aws_s3_bucket.user_data.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "user_data_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.user_data_ownership]

  bucket = aws_s3_bucket.user_data.id
  acl    = "private"
}

resource "aws_s3_object" "cw_agent_init" {
  bucket = aws_s3_bucket.user_data.id
  key    = "cw_agent_init.sh"
  content = templatefile("${path.module}/templates/cw_agent_init.sh", {
    metrics_enabled    = var.metrics_enabled
    prometheus_enabled = var.prometheus_enabled
    cw_agent_config = templatefile("${path.module}/config/cw_agent_config.json", {
      region = data.aws_region.current.name
    })
    cw_metrics_config = templatefile("${path.module}/config/cw_metrics_config.json", {
      cloudwatch_namespace = var.cloudwatch_namespace_ec2_metrics
    })
    cw_prometheus_config = templatefile("${path.module}/config/cw_prometheus_config.json", {
      prometheus_log_group_name = aws_cloudwatch_log_group.concourse.name
      prometheus_namespace      = var.cloudwatch_namespace_prometheus_metrics
    })
    prometheus_config = templatefile("${path.module}/config/prometheus_config.yml", {
      prometheus_bind_port = var.prometheus_bind_port
    })
  })
}

resource "aws_s3_object" "cw_agent_metrics_init" {
  bucket = aws_s3_bucket.user_data.id
  key    = "cw_agent_metrics_init.sh"
  content = templatefile("${path.module}/templates/cw_agent_metrics_init.sh", {
    metrics_enabled = var.metrics_enabled
  })
}

resource "aws_s3_object" "cw_agent_prometheus_init" {
  bucket = aws_s3_bucket.user_data.id
  key    = "cw_agent_prometheus_init.sh"
  content = templatefile("${path.module}/templates/cw_agent_prometheus_init.sh", {
    prometheus_enabled = var.prometheus_enabled
  })
}


resource "aws_s3_object" "web_user_data" {
  bucket      = aws_s3_bucket.user_data.id
  key         = "web_user_data.sh"
  content     = local.web_user_data_content
  source_hash = md5(local.web_user_data_content)
}

resource "aws_s3_object" "worker_user_data" {
  bucket      = aws_s3_bucket.user_data.id
  key         = "worker_user_data.sh"
  content     = local.worker_user_data_content
  source_hash = md5(local.worker_user_data_content)
}
