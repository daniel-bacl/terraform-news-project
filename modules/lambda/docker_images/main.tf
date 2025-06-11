provider "aws" {
  region = "ap-northeast-2"
}


# VPC
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["team-vpc"]
  }
}

# Private Subnets
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:Name"
    values = ["private-subnet-3b", "private-subnet-4d"]
  }
}

# RDS 보안 그룹 (태그 기반 자동 탐색)
data "aws_security_group" "rds_sg" {
  filter {
    name   = "tag:Name"
    values = ["rds-sg"]  # <- 실제 SG에 붙어있는 Name 태그
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

# RDS 인스턴스
data "aws_db_instance" "rds" {
  db_instance_identifier = "news-rds"
}

data "aws_iam_role" "lambda_exec_role" {
  name = "lambda_sql_initializer_role"
}

resource "aws_lambda_function" "news-crawler_mw" {
  function_name = "news-crawler-lambda"
  package_type  = "Image"
  image_uri     = var.docker_image_uri
  role          = data.aws_iam_role.lambda_exec_role.arn
  timeout       = 300
  memory_size   = 1024

 # Lambda가 RDS에 접근할 수 있도록 rds-sg를 직접 연결
  vpc_config {
    subnet_ids         = data.aws_subnets.private.ids
    security_group_ids = [data.aws_security_group.rds_sg.id]
  }

  environment {
    variables = {
      DB_HOST     = data.aws_db_instance.rds.address
      DB_PORT     = "3306"
      DB_USER     = "root"
      DB_PASSWORD = var.db_password
      DB_NAME     = "NewsSubscribe"
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


