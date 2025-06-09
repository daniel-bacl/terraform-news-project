
#// 변수 정의는 필요 시 여기에 추가하세요.

variable "db_host" {
  type    = string
  default   = ""
}

variable "db_user" {
  type    = string
  default = "root"
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = ""
}

variable "db_name" {
  type    = string
  default = "NewsSubscribe"
}

variable "db_charset" {
  type    = string
  default = "utf8mb4"
}

variable "ses_sender" {
  type    = string
  default = "News_send@sol-dni.click"
}

variable "layer_arn" {
  type    = string
  default = null
}

variable "environment" {
  type    = map(string)
  default = {}
}
