variable "name" {
  description = "RDS 인스턴스 이름"
  type        = string
}

variable "subnet_ids" {
  description = "RDS가 배치될 subnet들"
  type        = list(string)
}

variable "instance_class" {
  description = "RDS 인스턴스 타입"
  type        = string
}

variable "allocated_storage" {
  description = "스토리지 크기 (GB)"
  type        = number
}

variable "username" {
  description = "DB 관리자 계정"
  type        = string
}

variable "password" {
  description = "DB 관리자 비밀번호"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "초기 생성할 DB 이름"
  type        = string
}

variable "security_group_ids" {
  description = "접근 허용할 보안 그룹 목록"
  type        = list(string)
}
