terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.30"
    }
    grafana = {
      source  = "grafana/grafana"
      version = ">= 2.11"
    }
  }
}

module "grafana" {
  source  = "terraform-aws-modules/managed-service-grafana/aws"
  version = "~> 1.2"

  name = var.grafana_workspace_name
  account_access_type = "CURRENT_ACCOUNT"
  authentication_providers = ["AWS_SSO"]
  data_sources = ["CLOUDWATCH"]

  vpc_configuration = {
    subnet_ids = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
}

resource "aws_grafana_workspace_api_key" "terraform" {
  workspace_id    = module.grafana.workspace_id
  key_name        = "tf-provisioner"
  key_role        = "ADMIN"
  seconds_to_live = var.grafana_api_key_ttl
}

provider "grafana" {
  alias = "amg"
  url   = module.grafana.workspace_endpoint
  auth  = aws_grafana_workspace_api_key.terraform.key
}

resource "grafana_data_source" "cloudwatch" {
  provider   = grafana.amg
  name       = "CloudWatch"
  type       = "cloudwatch"
  is_default = false

  json_data_encoded = jsonencode({
    default_region = "ap-northeast-2"
    auth_type      = "default"
    assume_role_arn = var.monitoring_role_arn 
  })
}

# CloudWatch Alarm - RDS Replica Lag
resource "aws_cloudwatch_metric_alarm" "rds_lag" {
  alarm_name = "rds-replica-lag"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 1
  threshold = 60
  metric_name = "ReplicaLag"
  namespace = "AWS/RDS"
  period = 60
  statistic = "Maximum"
  dimensions = { DBInstanceIdentifier = var.rds_instance_id }
  alarm_description = "RDS ReplicaLag > 60s"
  alarm_actions = [var.alarm_sns_topic_arn]
}

# CloudWatch Alarm - Lambda Errors
resource "aws_cloudwatch_metric_alarm" "lambda_sending_news_error" {
  alarm_name = "lambda-sending-news-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 1
  threshold = 0
  metric_name = "Errors"
  namespace = "AWS/Lambda"
  period = 60
  statistic = "Sum"
  dimensions = { FunctionName = var.lambda_function_names["sending_news"] }
  alarm_description = "Lambda Sending News Error"
  alarm_actions = [var.alarm_sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "lambda_crawler_error" {
  alarm_name = "lambda-crawler-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 1
  threshold = 0
  metric_name = "Errors"
  namespace = "AWS/Lambda"
  period = 60
  statistic = "Sum"
  dimensions = { FunctionName = var.lambda_function_names["crawler"] }
  alarm_description = "Lambda Crawler Error"
  alarm_actions = [var.alarm_sns_topic_arn]
}

resource "grafana_dashboard" "overview" {
  provider = grafana.amg
  folder = "NewsSubscribe"
  config_json = templatefile("${path.module}/templates/system_overview.json.tftpl", {
    region = data.aws_region.current.name,
    rds = var.rds_instance_id,
    lambdas = var.lambda_function_names
  })
  depends_on = [grafana_data_source.cloudwatch]
}