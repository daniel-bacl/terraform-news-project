variable "function_name" {
  description = "Lambda function name"
  type        = string
}

variable "lambda_role_arn" {
  description = "Lambda execution role ARN"
  type        = string
}

variable "handler" {
  description = "Lambda 핸들러 (ex: lambda_function.lambda_handler)"
  type        = string
}

variable "runtime" {
  description = "Lambda 런타임 (ex: python3.11)"
  type        = string
}

variable "filename" {
  description = "배포할 Lambda zip 경로"
  type        = string
}

variable "layer_arn" {
  description = "ARN of Lambda layer to attach"
  type        = string
}

variable "environment" {
  description = "Environment variables for Lambda function"
  type        = map(string)
}

variable "subnet_ids" {
  description = "Lambda 함수가 실행될 subnet 리스트"
  type        = list(string)
}

variable "security_group_id" {
  description = "Lambda 함수에 할당할 보안 그룹 ID"
  type        = string
}

variable "db_charset" {
  type        = string
  description = "DB 문자셋 (기본값: utf8mb4)"
  default     = "utf8mb4"
}

variable "ses_sender" {
  type        = string
  description = "SES 발신 이메일 주소"
}