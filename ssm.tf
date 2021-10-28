# Use AWS default patch baselines for Ubuntu
data "aws_ssm_patch_baseline" "ubuntu_patch_baseline" {
  owner            = "AWS"
  name_prefix      = "AWS-"
  operating_system = "UBUNTU"
}

# I'm doing this in locals because according to terraform's documentation
# the return ID of an aws_ssm_patch_group is the name comma id (name,id).
# That seems gross to parse out with a split call, so let's just tie them
# together here with well organized code instead.
locals {
  web_patch_group_name    = "concourse-web"
  worker_patch_group_name = "concourse-worker"
}

# Keeping patch groups together with this locals block to reduce confusion.
resource "aws_ssm_patch_group" "web_patch_group" {
  baseline_id = data.aws_ssm_patch_baseline.ubuntu_patch_baseline.id
  patch_group = local.web_patch_group_name
}

resource "aws_ssm_patch_group" "worker_patch_group" {
  baseline_id = data.aws_ssm_patch_baseline.ubuntu_patch_baseline.id
  patch_group = local.worker_patch_group_name
}

# Web window, targets, and task
resource "aws_ssm_maintenance_window" "web_window" {
  name              = "concourse-web-patch-window"
  schedule          = var.web_patch_schedule
  schedule_timezone = var.schedule_timezone
  duration          = 1
  cutoff            = 0
}

resource "aws_ssm_maintenance_window_target" "web_targets" {
  window_id     = aws_ssm_maintenance_window.web_window.id
  name          = "concourse-web-patch-targets"
  description   = "Patches concourse web boxes."
  resource_type = "INSTANCE"

  targets {
    key    = "tag:Patch Group"
    values = [local.web_patch_group_name]
  }
}

resource "aws_ssm_maintenance_window_task" "patch_web_boxes" {
  name            = "patch-concourse-web"
  max_concurrency = "2"
  max_errors      = "0"
  task_arn        = "AWS-RunPatchBaseline"
  task_type       = "RUN_COMMAND"
  window_id       = aws_ssm_maintenance_window.web_window.id

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.web_targets.id]
  }
}

# Worker window, targets, and task
resource "aws_ssm_maintenance_window" "worker_window" {
  name              = "concourse-worker-patch-window"
  schedule          = var.worker_patch_schedule
  schedule_timezone = var.schedule_timezone
  duration          = 1
  cutoff            = 0
}

resource "aws_ssm_maintenance_window_target" "worker_targets" {
  window_id     = aws_ssm_maintenance_window.worker_window.id
  name          = "concourse-worker-patch-targets"
  description   = "Patches concourse worker boxes."
  resource_type = "INSTANCE"

  targets {
    key    = "tag:Patch Group"
    values = [local.worker_patch_group_name]
  }
}

resource "aws_ssm_maintenance_window_task" "patch_worker_boxes" {
  name            = "patch-concourse-workers"
  max_concurrency = "2"
  max_errors      = "0"
  task_arn        = "AWS-RunPatchBaseline"
  task_type       = "RUN_COMMAND"
  window_id       = aws_ssm_maintenance_window.worker_window.id

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.worker_targets.id]
  }
}
