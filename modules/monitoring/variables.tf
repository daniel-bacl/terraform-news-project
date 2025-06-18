variable "lambda_function_names" {
  type = map(string)
}

variable "rds_instance_id" {
  type        = string
}

variable "subnet_ids" {
  type        = list(string)
}

variable "security_group_ids" {
  type        = list(string)
}

variable "alarm_sns_topic_arn" {
  type = string
}

variable "grafana_workspace_name" {
  type    = string
  default = "news-subscribe-grafana"
}

variable "grafana_api_key_ttl" {
  type    = number
  default = 86400
}

variable "monitoring_role_arn" {
  type = string
}