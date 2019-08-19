provider "aws" {
  region = "${var.region}"
}

data "aws_route53_zone" "hosted_zone" {
  name         = "${var.hosted_zone}"
}

resource "aws_route53_record" "www" {
  zone_id = "${data.aws_route53_zone.hosted_zone.zone_id}"
  name    = "${var.route_53_url}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.bastion.private_ip}"]
}

resource "aws_security_group" "bastion-sg" {
  name   = "bastion-security-group"
  vpc_id = "${var.vpc_id}"

  ingress {
    protocol    = "tcp"
    from_port   = "${var.ssh_port}"
    to_port     = "${var.ssh_port}"
    cidr_blocks = "${var.ingress_cidr_blocks}"
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = "${var.ami}"
  key_name                    = "${aws_key_pair.bastion_key.key_name}"
  instance_type               = "${var.instance_type}"
  vpc_security_group_ids      = ["${aws_security_group.bastion-sg.id}"]
  associate_public_ip_address = false
  subnet_id                   = "${var.subnet_id}"
  iam_instance_profile        = "${aws_iam_instance_profile.bastion_profile.name}"

  root_block_device {
    delete_on_termination = false
  }
  tags {
    Name = "${var.name}"
  }

  # If Outgoing 22 is blocked, use specified port
  user_data = <<-EOF
    #!/bin/bash -ex
    perl -pi -e 's/^#?Port 22$/Port ${var.ssh_port}/' /etc/ssh/sshd_config
    service sshd restart || service ssh restart
    EOF
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "${var.name}_key"
  public_key = "${var.public_key}"
}


output "bastion_private_ip" {
  value = "${aws_instance.bastion.private_ip}"
}

