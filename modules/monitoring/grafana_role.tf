# IAM 정책 정의 (jsonencode 사용)
resource "aws_iam_policy" "grafana_cloudwatch" {
  name        = "grafana-cloudwatch-policy"
  description = "Policy for Grafana to access CloudWatch and CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:GetDashboard",
          "cloudwatch:DescribeAlarmsForMetric",
          "cloudwatch:DescribeAlarmHistory",
          "cloudwatch:GetInsightRuleReport",
          "logs:GetLogGroupFields",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:StartQuery",
          "logs:StopQuery",
          "logs:GetQueryResults",
          "logs:FilterLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

# IRSA용 IAM 역할 생성
resource "aws_iam_role" "grafana_irsa" {
  name = "eks-irsa-grafana"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = var.eks_oidc_provider_arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(var.eks_oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:${var.grafana_service_account_namespace}:${var.grafana_service_account_name}"
          }
        }
      }
    ]
  })
}

# 정책과 역할 연결
resource "aws_iam_role_policy_attachment" "grafana_attach" {
  role       = aws_iam_role.grafana_irsa.name
  policy_arn = aws_iam_policy.grafana_cloudwatch.arn
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.grafana_service_account_namespace
  }
}

# Grafana ServiceAccount (Helm과 연동하려면 이 이름 지정 필요)
resource "kubernetes_service_account" "grafana" {
  provider = kubernetes
  
  metadata {
    name      = var.grafana_service_account_name
    namespace = var.grafana_service_account_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.grafana_irsa.arn
    }
  }

  depends_on = [kubernetes_namespace.monitoring]
}
