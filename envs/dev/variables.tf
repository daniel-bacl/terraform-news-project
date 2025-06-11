#// 변수 정의는 필요 시 여기에 추가하세요.

variable "db_host" {
  type    = string
  default = ""
}

variable "db_user" {
  type    = string
  default = "root"
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = "soldesk12!"
}

variable "db_name" {
  type    = string
  default = "NewsSubscribe"
}

variable "ses_sender" {
  type    = string
  default = "News_send@sol-dni.click"
}

variable "pymysql_layer_arn" {
  type    = string
  default = null
}

variable "environment" {
  type    = map(string)
  default = {}
}

variable "private_subnet_ids" {
  type = list(string)
  default = ["private_3b", "private_4d"]  # 실제 서브넷 ID로 변경
}

variable "lambda_sg_id" {
  type    = string
  default = "app_sg_id"  # 실제 보안 그룹 ID로 변경
}