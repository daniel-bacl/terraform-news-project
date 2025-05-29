// 변수 정의는 필요 시 여기에 추가하세요.
variable "db_password" {
  type      = string
  sensitive = true
  default = ""
}
