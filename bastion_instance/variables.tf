variable "vpc_id" {}
variable "subnet_id" {}
variable "public_key" {}
variable "instance_role_name" {}
variable "hosted_zone" {}
variable "route_53_url" {}

variable "instance_type" {
  default = "t3.nano"
}
variable "name" {
  default = "Bastion"
}
variable "ssh_port" {
  default = 22
}
variable "ami" {
  default = "ami-0ab7944c6328200be"
}
variable "ingress_cidr_blocks" {
  default = ["10.0.0.0/8"]
  type = "list"
}

variable "region" {
  default = "eu-west-1"
}

