variable "function_name" {
  description = "Lambda 함수 이름"
  type        = string
}

variable "lambda_role_arn" {
  description = "Lambda 실행 역할 ARN"
  type        = string
}

variable "handler" {
  description = "Lambda 핸들러 (예: lambda_function.lambda_handler)"
  type        = string
}

variable "runtime" {
  description = "Lambda 런타임 (예: python3.11)"
  type        = string
}

variable "filename" {
  description = "배포할 Lambda zip 파일 경로"
  type        = string
}

variable "pymysql_layer_arn" {
  description = "연결할 Lambda Layer ARN"
  type        = string
}

variable "environment" {
  description = "Lambda 환경 변수들 (예: DB 정보)"
  type        = map(string)
}

variable "subnet_ids" {
  description = "Lambda가 연결될 서브넷 ID 리스트"
  type        = list(string)
}

variable "security_group_id" {
  description = "Lambda에 연결할 보안 그룹 ID"
  type        = string
}