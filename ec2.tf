#---------------------------------------------------------
# Concourse worker farm.
#---------------------------------------------------------
resource "aws_instance" "concourse_worker" {
  count      = "${var.worker_count}"
  depends_on = ["aws_elb.concourse_lb"]

  ami                  = "${data.aws_ami.base_ami.id}"
  instance_type        = "${var.worker_instance_type}"
  iam_instance_profile = "${var.worker_instance_profile}"

  # We're doing some magic here to allow for any number of count that's evenly distributed
  # across the configured subnets.
  subnet_id = "${var.worker_subnets[count.index % length(var.worker_subnets)]}"

  key_name = "${var.conc_key_name}"

  vpc_security_group_ids = [
    "${var.utility_accessible_sg}",
    "${aws_security_group.worker_sg.id}",
  ]

  tags {
    Name = "Concourse Worker"
  }

  root_block_device {
    volume_size = "${var.worker_vol_size}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/concourse/keys",
      "sudo chown -R ubuntu:ubuntu /etc/concourse",
      "mkdir -p ~/keys",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = "${self.private_ip}"
      private_key = "${file("${path.root}/${var.conc_key_path}/${var.conc_key_name}.pem")}"
    }
  }

  provisioner "file" {
    source      = "${var.worker_keys_dir}"
    destination = "~/keys/"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = "${self.private_ip}"
      private_key = "${file("${path.root}/${var.conc_key_path}/${var.conc_key_name}.pem")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo unattended-upgrade -d",
      "sudo apt-get remove docker docker-engine docker.io",
      "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce",
      "sudo docker pull ${var.conc_image}",
      "sudo mv ~/keys /etc/concourse/",
      "sudo find /etc/concourse/keys/ -type f -exec chmod 400 {} \\;",
      "sudo docker run -d --name concourse_worker --privileged=true --restart=unless-stopped -h ${self.private_dns} -v /etc/concourse/keys/:/concourse-keys -v /tmp/:/concourse-tmp -p 7777:7777 -p 7788:7788 -p 7799:7799 ${var.conc_image} worker --bind-ip ${var.worker_bind_ip} --baggageclaim-bind-ip ${var.worker_bind_ip} --garden-bind-ip ${var.worker_bind_ip} --peer-ip ${self.private_ip} --tsa-host ${aws_elb.concourse_lb.dns_name}:2222 --work-dir /concourse-tmp --garden-dns-proxy-enable ${var.worker_launch_options}",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = "${self.private_ip}"
      private_key = "${file("${path.root}/${var.conc_key_path}/${var.conc_key_name}.pem")}"
    }
  }
}
