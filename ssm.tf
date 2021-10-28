resource "aws_ssm_maintenance_window" "web_window" {
  name              = "concourse-web-patch-window"
  schedule          = "cron(${var.web_patch_crontab})"
  schedule_timezone = var.schedule_timezone
  duration          = 1
  cutoff            = 0
}

resource "aws_ssm_maintenance_window" "worker_window" {
  name              = "concourse-worker-patch-window"
  schedule          = "cron(${var.worker_patch_crontab})"
  schedule_timezone = var.schedule_timezone
  duration          = 1
  cutoff            = 0
}

resource "aws_ssm_maintenance_window_task" "patch_web_boxes" {
  max_concurrency = "2"
  max_errors      = "0"
  task_arn        = "AWS-RunPatchBaseline"
  task_type       = "AUTOMATION"
  window_id       = aws_ssm_maintenance_window.web_window.id
}

resource "aws_ssm_maintenance_window_task" "patch_worker_boxes" {
  max_concurrency = "2"
  max_errors      = "0"
  task_arn        = "AWS-RunPatchBaseline"
  task_type       = "AUTOMATION"
  window_id       = aws_ssm_maintenance_window.worker_window.id
}

# Use AWS default patch baselines for Ubuntu
data "aws_ssm_patch_baseline" "ubuntu_patch_baseline" {
  owner            = "AWS"
  name_prefix      = "AWS-"
  operating_system = "Ubuntu"
}

resource "aws_ssm_patch_group" "web_patch_group" {
  baseline_id = data.aws_ssm_patch_baseline.ubuntu_patch_baseline.id
  patch_group = "concourse-web"
}

resource "aws_ssm_patch_group" "worker_patch_group" {
  baseline_id = data.aws_ssm_patch_baseline.ubuntu_patch_baseline.id
  patch_group = "concourse-worker"
}