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

data "aws_iam_policy" "cloudwatch_agent_policy" {
  name = "CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policies" {
  role       = aws_iam_role.concourse_role.name
  policy_arn = data.aws_iam_policy.cloudwatch_agent_policy.arn
}

resource "aws_iam_role_policy" "s3_get_user_data" {
  name = "ConcourseCI-S3-Retrieve-UserData"
  role = aws_iam_role.concourse_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
