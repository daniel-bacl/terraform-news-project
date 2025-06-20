# --------------------
# Grafana 설정용
# --------------------

locals {
  kubelet_dashboard_json = jsonencode(jsondecode(file("${path.module}/grafana_dashboard/kubelet.json")))

  grafana_values = templatefile("${path.module}/grafana-values.tpl.yaml", {
    region = var.region
    rds    = var.rds_instance_id
    lambdas = {
      sending_news = var.lambda_function_names["sending_news"]
      crawler      = var.lambda_function_names["crawler"]
    }
    kubelet_json = local.kubelet_dashboard_json
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
# CloudWatch Log Metric Filter - Mail Send Success 감지
# --------------------
resource "aws_cloudwatch_log_metric_filter" "lambda_mail_success" {
  name           = "lambda-mail-success"
  log_group_name = "/aws/lambda/news-lambda-handler"
  pattern        = "Mail Send Success"

  metric_transformation {
    name      = "MailSendSuccess"
    namespace = "Lambda/Mail"
    value     = "1"
  }
}

# --------------------
# CloudWatch Metric Alarm - Mail Send Success 알람
# --------------------
resource "aws_cloudwatch_metric_alarm" "mail_success_alarm" {
  alarm_name          = "MailSendSuccessAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.lambda_mail_success.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.lambda_mail_success.metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Mail Send Success 로그가 감지됨"
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

# --------------------
# CloudWatch Dashboard (RDS CPU + Lambda 로그 쿼리)
# --------------------
locals {
  lambda_fail_query    = "fields @timestamp, @message | filter @message like /실패/ | sort @timestamp desc | limit 20"
  lambda_success_query = "fields @timestamp, @message | filter @message like /성공/ | sort @timestamp desc | limit 20"
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "main-monitoring"
  dashboard_body = templatefile("${path.module}/dashboard_body.json.tmpl", {
    rds_instance_id      = var.rds_instance_id,
    region               = var.region,
    lambda_fail_query    = local.lambda_fail_query,
    lambda_success_query = local.lambda_success_query
  })
}
