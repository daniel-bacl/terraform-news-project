resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_metric_filter" "ses_success_filter" {
  name           = "ses_success_count"
  log_group_name = aws_cloudwatch_log_group.lambda_log_group.name
  pattern        = "[level=INFO, message=\"[메일 전송 성공]*\"]"

  metric_transformation {
    name      = "SuccessCount"
    namespace = "LambdaNewsDelivery"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "ses_fail_filter" {
  name           = "ses_fail_count"
  log_group_name = aws_cloudwatch_log_group.lambda_log_group.name
  pattern        = "[level=ERROR, message=\"[메일 전송 실패]*\"]"

  metric_transformation {
    name      = "FailCount"
    namespace = "LambdaNewsDelivery"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "ses_fail_alarm" {
  alarm_name          = "${var.lambda_function_name}-ses-failure-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FailCount"
  namespace           = "LambdaNewsDelivery"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "SES 이메일 전송 실패 발생"
  actions_enabled     = true
  alarm_actions       = [var.alert_sns_topic_arn]
}

