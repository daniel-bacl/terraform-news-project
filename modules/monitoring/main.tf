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
  endpoint  = each.value # 알림 받을 이메일 주소 (variables.tf 참고)
}

# --------------------
# CloudWatch Log Metric Filter - Lambda [메일 전송 실패] 감지
# --------------------
resource "aws_cloudwatch_log_metric_filter" "lambda_mail_fail" {
  name           = "lambda-mail-fail"
  log_group_name = "/aws/lambda/news-lambda-handler"
  pattern        = "[메일 전송 실패]"

  metric_transformation {
    name      = "MailSendFail"
    namespace = "Lambda/Mail"
    value     = "1"
  }
}

# --------------------
# CloudWatch Metric Alarm - [메일 전송 실패] 알람
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
  alarm_description   = "[메일 전송 실패] 로그가 감지됨"
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
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "main-monitoring"
  dashboard_body = jsonencode({
    widgets = [
      {
        "type": "metric",
        "x": 0,
        "y": 0,
        "width": 8,
        "height": 6,
        "properties": {
          "metrics": [
            [ "AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_instance_id ]
          ],
          "period": 300,
          "stat": "Average",
          "region": var.region,
          "title": "RDS CPU 사용률"
        }
      },
      {
        "type": "log",
        "x": 8,
        "y": 0,
        "width": 8,
        "height": 6,
        "properties": {
          "query": "fields @timestamp, @message | filter @message like /\\[메일 전송 실패\\]/ | sort @timestamp desc | limit 20",
          "region": var.region,
          "title": "Lambda: [메일 전송 실패] 로그"
        },
        "logGroupNames": [
          "/aws/lambda/news-crawler-lambda",
          "/aws/lambda/news-lambda-handler"
        ]
      },
      {
        "type": "log",
        "x": 8,
        "y": 6,
        "width": 8,
        "height": 6,
        "properties": {
          "query": "fields @timestamp, @message | filter @message like /\\[메일 전송 성공\\]/ | sort @timestamp desc | limit 20",
          "region": var.region,
          "title": "Lambda: [메일 전송 성공] 로그"
        },
        "logGroupNames": [
          "/aws/lambda/news-crawler-lambda",
          "/aws/lambda/news-lambda-handler"
        ]
      }
    ]
  })
}
