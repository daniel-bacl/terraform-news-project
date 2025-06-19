#// 변수 정의는 필요 시 여기에 추가하세요.

variable "lambda_env" {
  type = map(string)
  default = {
    DB_USER     = "root"
    DB_PASSWORD = "soldesk12!"
    DB_NAME     = "NewsSubscribe"
    SES_SENDER  = "News_send@sol-dni.click"
  }
}

variable "private_subnet_ids" {
  type = list(string)
  default = ["private_3b", "private_4d"]  # 실제 서브넷 ID로 변경
}

variable "lambda_sg_id" {
  type    = string
  default = "app_sg_id"  # 실제 보안 그룹 ID로 변경
}

variable "docker_image_uri" {
  type = string
  sensitive = true
  default = "635140758252.dkr.ecr.ap-northeast-2.amazonaws.com/news-crawler:latest"
}

variable "grafana_admin_password" {
  type = string
  default = "SuperSecret123"
}

variable "account_id" {
  default = "635140758252"
}