resource "aws_lambda_function" "news-crawler_mw" {
  function_name = "news-crawler-lambda"
  package_type  = "Image"
  image_uri     = var.docker_image_uri
  role          = var.lambda_exec_role_arn
  timeout       = 120

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.rds_sg_id]
  }

  environment {
    variables = {
      DB_HOST     = var.rds_endpoint
      DB_PORT     = var.rds_port
      DB_NAME     = var.rds_db_name
      DB_USER     = var.rds_username
      DB_PASSWORD = var.db_password
    }
  }
}
# EventBridge Rule (스케줄 트리거 설정)
resource "aws_cloudwatch_event_rule" "lambda_schedule_rule" {
  name                = "news-crawler-schedule-rule"
  description         = "Runs Lambda function on a schedule"
  schedule_expression = "rate(1 hour)"  # 매 1시간마다 실행되는 스케줄 설정

  tags = {
    Name = "news-crawler-schedule-rule"
  }
}

# Lambda 권한 부여 (EventBridge → Lambda)
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"  # Lambda 실행 권한 부여
  function_name = aws_lambda_function.news-crawler_mw.function_name  # 대상 Lambda 함수 이름
  principal     = "events.amazonaws.com"  # EventBridge 서비스
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule_rule.arn  # EventBridge 규칙의 ARN (허용된 소스)
}

# EventBridge Rule → Lambda 연결 (타깃)
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule_rule.name  # 연결할 EventBridge 규칙 이름
  target_id = "lambda-news-crawler"  # 이 타깃을 식별하기 위한 ID
  arn       = aws_lambda_function.news-crawler_mw.arn  # 호출할 Lambda 함수의 ARN
}


