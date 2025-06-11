provider "aws" {
  region = "ap-northeast-2"
}

############################
# VPC & Subnets
############################

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["team-vpc"]
  }
}

# Private Subnets: Lambda가 배치될 위치
data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:kubernetes.io/role/internal-elb"
    values = ["1"]
  }
}

# ✅ Public Subnet 1개 자동 선택 (NAT 배치용)
data "aws_subnet" "public_subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:kubernetes.io/role/elb"
    values = ["1"]
  }

}

############################
# NAT Gateway 구성
############################

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = data.aws_subnet.public_subnet.id

  tags = {
    Name = "nat-gateway"
  }

  depends_on = [aws_eip.nat_eip]
}

resource "aws_route_table" "private_rt" {
  vpc_id = data.aws_vpc.selected.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private_rta" {
  for_each = toset(data.aws_subnets.private_subnets.ids)

  subnet_id      = each.key
  route_table_id = aws_route_table.private_rt.id
}

############################
# 보안 그룹 (기존 것 참조)
############################

data "aws_security_group" "app_sg" {
  filter {
    name   = "group-name"
    values = ["app-sg"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_security_group" "rds_sg" {
  filter {
    name   = "group-name"
    values = ["rds-sg"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

############################
# Lambda SG (신규 생성)
############################

resource "aws_security_group" "lambda_sg" {
  name        = "lambda-sg"
  description = "Lambda SG for accessing RDS"
  vpc_id      = data.aws_vpc.selected.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lambda-sg"
  }
}

resource "aws_security_group_rule" "allow_lambda_to_rds" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = data.aws_security_group.rds_sg.id
  source_security_group_id = aws_security_group.lambda_sg.id
  description              = "Allow Lambda to access RDS"
}

############################
# RDS 인스턴스 정보
############################

data "aws_db_instance" "rds" {
  db_instance_identifier = "news-rds"
}

############################
# Lambda 함수
############################

resource "aws_lambda_function" "news_crawler" {
  function_name = var.function_name
  package_type  = "Image"
  image_uri     = var.image_uri
  role          = var.lambda_role_arn
  timeout       = 120
  memory_size   = 512

  vpc_config {
    subnet_ids         = data.aws_subnets.private_subnets.ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      DB_HOST     = data.aws_db_instance.rds.endpoint
      DB_PORT     = "3306"
      DB_USER     = var.db_user
      DB_PASSWORD = var.db_password
      DB_NAME     = var.db_name
    }
  }

  depends_on = [
    aws_security_group.lambda_sg,
    aws_security_group_rule.allow_lambda_to_rds
  ]
}

############################
# CloudWatch 스케줄링
############################

resource "aws_cloudwatch_event_rule" "news_crawler_cron" {
  name                = "news-crawler-schedule"
  description         = "매일 아침 8시에 뉴스 크롤러 실행"
  schedule_expression = "cron(0 23 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_schedule_target" {
  rule      = aws_cloudwatch_event_rule.news_crawler_cron.name
  target_id = "news-crawler-lambda"
  arn       = aws_lambda_function.news_crawler.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.news_crawler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.news_crawler_cron.arn
}

