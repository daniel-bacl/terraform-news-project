# --------------------
# Grafana 설정용
# --------------------

locals {
  cloudWatch_dashboard_json        = jsonencode(jsondecode(file("${path.module}/grafana_dashboard/cloudwatch.json")))
  kubelet_dashboard_json = jsonencode(jsondecode(file("${path.module}/grafana_dashboard/kubelet.json")))

  grafana_values = templatefile("${path.module}/grafana-values.tpl.yaml", {
    kubelet_json = local.kubelet_dashboard_json
    cloudwatch_json = local.cloudWatch_dashboard_json
  })
}

resource "helm_release" "grafana" {
  provider = helm

  name             = "grafana-monitoring"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  version          = "7.3.7"
  namespace        = "monitoring"
  create_namespace = true

  values = [ local.grafana_values ]

  set = [
    {
      name  = "adminPassword"
      value = var.grafana_admin_password
    },
    {
      name  = "service.type"
      value = "ClusterIP"
    },
    {
      name  = "serviceAccount.name"
      value = kubernetes_service_account.grafana.metadata[0].name
    },
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "rbac.create"
      value = "true"
    },
    {
      name  = "datasources.datasource.yaml.apiVersion"
      value = "1"
    }
  ]

  depends_on = [kubernetes_namespace.monitoring]
}

# --------------------
# SNS (알림 전송)
# --------------------
resource "aws_sns_topic" "monitoring_alerts" {
  name = "monitoring-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  for_each = toset(var.alert_emails)
  topic_arn = aws_sns_topic.monitoring_alerts.arn
  protocol  = "email"
  endpoint  = each.value
}

# --------------------
# CloudWatch Log Metric Filter - Mail Send Fail 감지
# --------------------
resource "aws_cloudwatch_log_metric_filter" "lambda_mail_fail" {
  name           = "lambda-mail-fail"
  log_group_name = "/aws/lambda/news-lambda-handler"
  pattern        = "Mail Send Fail"

  metric_transformation {
    name      = "MailSendFail"
    namespace = "Lambda/Mail"
    value     = "1"
  }
}

# --------------------
# CloudWatch Metric Alarm - Mail Send Fail 알람
# --------------------
resource "aws_cloudwatch_metric_alarm" "mail_fail_alarm" {
  alarm_name          = "MailSendFailAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.lambda_mail_fail.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.lambda_mail_fail.metric_transformation[0].namespace
  period              = 300

  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Mail Send Fail 로그가 감지됨"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.monitoring_alerts.arn]
}


# --------------------
# RDS CPU 사용률 알람
# --------------------
resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "RDS-CPU-High"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "RDS 인스턴스 CPU 70% 초과"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.monitoring_alerts.arn]
  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }
}

