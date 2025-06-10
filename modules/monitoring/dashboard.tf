resource "aws_cloudwatch_dashboard" "lambda_email_dashboard" {
  dashboard_name = "${var.lambda_function_name}-email-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "log",
        x    = 0,
        y    = 0,
        width = 24,
        height = 8,
        properties = {
          title  = "✅ 이메일 전송 성공 로그",
          query  = "SOURCE '/aws/lambda/${var.lambda_function_name}' | filter @message like /메일 전송 성공/ | sort @timestamp desc | limit 20",
          region = var.aws_region,
          view   = "table"
        }
      },
      {
        type = "log",
        x    = 0,
        y    = 8,
        width = 24,
        height = 8,
        properties = {
          title  = "❌ 이메일 전송 실패 로그",
          query  = "SOURCE '/aws/lambda/${var.lambda_function_name}' | filter @message like /메일 전송 실패/ | sort @timestamp desc | limit 20",
          region = var.aws_region,
          view   = "table"
        }
      }
    ]
  })
}

