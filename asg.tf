locals {
  web_interpolation_vars = {
    "authorized_worker_keys"       = file(var.web_authorized_keys_path)
    "session_signing_key"          = file(var.web_session_signing_key_path)
    "tsa_host_key"                 = file(var.web_tsa_host_key_path)
    "conc_version"                 = var.conc_version
    "concdb_host"                  = var.concdb_host
    "concdb_port"                  = var.concdb_port
    "concdb_user"                  = var.concdb_user
    "concdb_password"              = var.concdb_password
    "concdb_database"              = var.concdb_database
    "conc_fqdn"                    = var.conc_fqdn
    "container_placement_strategy" = var.container_placement_strategy
    "authentication_config"        = var.authentication_config
    "cred_store_config"            = var.cred_store_config
    "feature_flags"                = var.web_feature_flags
    "concourse_base_resource_type_defaults"  = yamlencode(var.concourse_base_resource_type_defaults)
  }

  worker_interpolation_vars = {
    "tsa_public_key" = file(var.tsa_public_key_path)
    "worker_key"     = file(var.worker_key_path)
    "conc_version"   = var.conc_version
    "tsa_host"       = aws_elb.concourse_lb.dns_name
    "storage_driver" = var.worker_container_storage_driver
    "dns_servers"    = var.worker_dns_servers
    "feature_flags"  = var.worker_feature_flags
  }
}

resource "aws_launch_template" "web_template" {
  name          = "conc-web-tmpl"
  instance_type = var.web_instance_type
  key_name      = var.conc_key_name
  image_id      = data.aws_ami.base_ami.id

  vpc_security_group_ids = [
    aws_security_group.web_sg.id,
    aws_security_group.allow_workers_to_web.id,
    var.utility_accessible_sg,
  ]

  user_data = base64encode(templatefile("${path.module}/templates/web_user_data.sh", local.web_interpolation_vars))

  iam_instance_profile {
    name = aws_iam_instance_profile.concourse_profile.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web_asg" {
  name = "concweb-asg-${aws_launch_template.web_template.latest_version}"

  health_check_type   = "EC2"
  desired_capacity    = var.web_desired_count
  min_size            = var.web_min_count
  max_size            = var.web_max_count
  vpc_zone_identifier = flatten([var.web_private_subnets])
  load_balancers      = [aws_elb.concourse_lb.name]

  launch_template {
    id      = aws_launch_template.web_template.id
    version = "$Latest"
  }

  depends_on = [aws_launch_template.web_template]

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }

  tag {
    key                 = "Name"
    value               = "Concourse Web"
    propagate_at_launch = true
  }

  tag {
    key                 = "Patch Group"
    value               = local.web_patch_group_name
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "web_asg_to_lb" {
  autoscaling_group_name = aws_autoscaling_group.web_asg.id
  elb                    = aws_elb.concourse_lb.id
}

resource "aws_launch_template" "worker_template" {
  name          = "conc-worker-tmpl"
  instance_type = var.worker_instance_type
  key_name      = var.conc_key_name
  image_id      = data.aws_ami.base_ami.id

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type = "gp2"
      volume_size = var.worker_vol_size
    }
  }

  vpc_security_group_ids = [
    var.utility_accessible_sg,
    aws_security_group.worker_sg.id,
  ]

  user_data = base64encode(templatefile("${path.module}/templates/worker_user_data.sh", local.worker_interpolation_vars))

  iam_instance_profile {
    name = aws_iam_instance_profile.concourse_profile.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "worker_asg" {
  name = "concwkr-asg-${aws_launch_template.worker_template.latest_version}"

  health_check_type   = "EC2"
  desired_capacity    = var.worker_desired_count
  min_size            = var.worker_min_count
  max_size            = var.worker_max_count
  vpc_zone_identifier = flatten([var.worker_private_subnets])

  launch_template {
    id      = aws_launch_template.worker_template.id
    version = "$Latest"
  }

  depends_on = [aws_launch_template.worker_template]

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }

  tag {
    key                 = "Name"
    value               = "Concourse Worker"
    propagate_at_launch = true
  }

  tag {
    key                 = "Patch Group"
    value               = local.worker_patch_group_name
    propagate_at_launch = true
  }
}
