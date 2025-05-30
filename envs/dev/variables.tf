// 변수 정의는 필요 시 여기에 추가하세요.

variable "db_host" {
  type    = string
  default = "newssubscribe.cb0ueo6m8a54.ap-northeast-2.rds.amazonaws.com"
}

variable "db_user" {
  type    = string
  default = "root"
}

variable "db_password" {
<<<<<<< Updated upstream
  type      = string
  sensitive = true
  default = ""
=======
  type    = string
  default = "soldesk12!"
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
=======

>>>>>>> Stashed changes
