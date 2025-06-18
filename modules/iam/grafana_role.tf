resource "aws_iam_role" "terraform_monitoring_role" {
  name = "terraform-monitoring-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "terraform_monitoring_policy" {
  name = "terraform-monitoring-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "cloudwatch:*",
        "logs:*",
        "grafana:*",
        "ec2:DescribeInstances",
        "rds:DescribeDBInstances",
        "lambda:ListFunctions",
        "iam:PassRole"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_monitoring_policy" {
  role = aws_iam_role.terraform_monitoring_role.name
  policy_arn = aws_iam_policy.terraform_monitoring_policy.arn
}