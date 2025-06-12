# --------------------------------------------
# Lambda 함수 zip 파일 생성 (자동으로 .zip 생성)
# --------------------------------------------
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

# --------------------------------------------
# Lambda CloudWatch 로그 그룹
# --------------------------------------------
#resource "aws_cloudwatch_log_group" "lambda_logs" {
#  name              = "/aws/lambda/${var.function_name}"
#  retention_in_days = 14

#  tags = {
#    Name = "Lambda Log Group"
#  }
#}

# --------------------------------------------
# Lambda 함수 리소스
# --------------------------------------------
resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = var.lambda_role_arn
  handler       = var.handler
  runtime       = var.runtime

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  layers = [var.pymysql_layer_arn]

  environment {
    variables = var.environment
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [var.security_group_id]
  }
}

# --------------------------------------------
# Lambda CloudWatch Trigger
# --------------------------------------------
# ✅ CloudWatch Event Rule: 평일 매시 정각 실행
resource "aws_cloudwatch_event_rule" "weekday_hourly_trigger" {
  name                = "send-news-lambda-weekday-trigger"
  description         = "Trigger Lambda every weekday at the top of the hour"
  schedule_expression = "cron(0 * ? * MON-FRI *)"
}

# ✅ CloudWatch -> Lambda 타겟 연결
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.weekday_hourly_trigger.name
  target_id = "send-news-lambda"
  arn       = aws_lambda_function.this.arn
}

# ✅ Lambda 권한 허용
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.weekday_hourly_trigger.arn
}
