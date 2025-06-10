output "cloudwatch_log_group_name" {
  description = "Lambda용 CloudWatch 로그 그룹 이름"
  value       = aws_cloudwatch_log_group.lambda_log_group.name
}

output "ses_fail_alarm_name" {
  description = "SES 실패 알람 이름"
  value       = aws_cloudwatch_metric_alarm.ses_fail_alarm.alarm_name
}

output "dashboard_name" {
  value       = aws_cloudwatch_dashboard.lambda_email_dashboard.dashboard_name
  description = "생성된 CloudWatch Dashboard 이름"
}

