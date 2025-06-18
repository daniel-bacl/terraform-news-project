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
# CloudWatch Log Metric Filter - Lambda MAIL_SEND_FAIL 감지
# --------------------
resource "aws_cloudwatch_log_metric_filter" "lambda_mail_fail" {
  name           = "lambda-mail-fail"
  log_group_name = "/aws/lambda/news-lambda-handler"
  pattern        = "MAIL_SEND_FAIL"

  metric_transformation {
    name      = "MailSendFail"
    namespace = "Lambda/Mail"
    value     = "1"
  }
}

# --------------------
# CloudWatch Metric Alarm - MAIL_SEND_FAIL 알람
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
  alarm_description   = "MAIL_SEND_FAIL 로그가 감지됨"
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
  lambda_fail_query = <<EOT
fields @timestamp, @message
| filter @message like /실패/
| sort @timestamp desc
| limit 20
EOT

  lambda_success_query = <<EOT
fields @timestamp, @message
| filter @message like /성공/
| sort @timestamp desc
| limit 20
EOT
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "main-monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 8
        height = 6
        properties = {
          metrics = [
            [ "AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_instance_id ]
          ],
          period = 300,
          stat   = "Average",
          region = var.region,
          title  = "RDS CPU 사용률"
        }
      },
      {
        type   = "log"
        x      = 8
        y      = 0
        width  = 8
        height = 6
        properties = {
          query         = replace(local.lambda_fail_query, "\n", "\\n"),
          region        = var.region,
          title         = "Lambda: MAIL_SEND_FAIL 로그",
          logGroupNames = ["/aws/lambda/news-lambda-handler"],
          view          = "table",
          stacked       = false
        }
      },
      {
        type   = "log"
        x      = 8
        y      = 6
        width  = 8
        height = 6
        properties = {
          query         = replace(local.lambda_success_query, "\n", "\\n"),
          region        = var.region,
          title         = "Lambda: MAIL_SEND_SUCCESS 로그",
          logGroupNames = ["/aws/lambda/news-lambda-handler"],
          view          = "table",
          stacked       = false
        }
      }
    ]
  })
}

