resource "aws_iam_instance_profile" "concourse_profile" {
  name = "concourse-instance-profile"
  role = aws_iam_role.concourse_role.name
}

resource "aws_iam_role" "concourse_role" {
  name        = "ConcourseCI"
  description = "Houses permissions for concourse nodes inside our network."

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "concourse_permissions" {
  count      = length(var.custom_policy_arns)
  role       = aws_iam_role.concourse_role.name
  policy_arn = var.custom_policy_arns[count.index]
}

data "aws_iam_policy" "aws_ssm_default" {
  name = "AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "add_ssm_for_patching" {
  role       = aws_iam_role.concourse_role.name
  policy_arn = data.aws_iam_policy.aws_ssm_default.arn
}