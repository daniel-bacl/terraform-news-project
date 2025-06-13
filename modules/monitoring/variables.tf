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
