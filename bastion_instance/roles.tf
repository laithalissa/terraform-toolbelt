data "aws_iam_policy" "administrator_access" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy_document" "bastion_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role" "bastion_role" {
  name = "${var.name}_role"
  path = "/"
  assume_role_policy = "${data.aws_iam_policy_document.bastion_assume_role_policy.json}"
}

resource "aws_iam_role_policy_attachment" "bastion_role_policy_attachment" {
  role = "${aws_iam_role.bastion_role.name}"
  policy_arn = "${data.aws_iam_policy.administrator_access.arn}"
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "${var.name}_profile"
  role = "${aws_iam_role.bastion_role.id}"
}
