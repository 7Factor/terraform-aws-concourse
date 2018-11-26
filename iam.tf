resource "aws_iam_instance_profile" "concourse_profile" {
  name = "concourse_instance_profile"
  role = "${aws_iam_role.concourse_role.name}"
}

resource "aws_iam_role_policy_attachment" "concourse_permissions" {
  role       = "${aws_iam_role.concourse_role.name}"
  policy_arn = "${aws_iam_policy.concourse_policy.arn}"
}

resource "aws_iam_role" "concourse_role" {
  name        = "Concourse"
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

resource "aws_iam_policy" "concourse_policy" {
  name = "ConcourseAccess"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "route53:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ecs:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ecr:*",
      "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": "elasticloadbalancing:*",
        "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": "s3:*",
        "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": "rds:*",
        "Resource": "*"
    }
  ]
}
EOF
}
