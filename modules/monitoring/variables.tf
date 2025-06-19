variable "region" {
  type = string
}

variable "rds_instance_id" {
  description = "RDS DBInstanceIdentifier"
  type        = string
}

variable "alert_emails" {
  description = "알림을 받을 이메일 리스트"
  type        = list(string)
  default = []
}

variable "lambda_function_names" {
  description = "모니터링할 Lambda 함수들의 이름 맵"
  type        = map(string)
  default     = {}
}

variable "grafana_admin_password" {
  description = "Grafana EC2/Docker 배포 시 admin 비밀번호"
  type        = string
  default     = ""
}

variable "grafana_service_account_namespace" {
  type    = string
  default = "monitoring"
}

variable "grafana_service_account_name" {
  type    = string
  default = "grafana"
}

variable "eks_oidc_provider_arn" {
  type = string
}

variable "eks_oidc_provider_url" {
  type = string
}
