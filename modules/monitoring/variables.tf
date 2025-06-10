variable "lambda_function_name" {
  description = "CloudWatch 로그 그룹 이름 생성에 사용될 Lambda 함수 이름"
  type        = string
}

variable "alert_sns_topic_arn" {
  description = "CloudWatch 알람 시 알림을 전송할 SNS 주제 ARN"
  type        = string
}

variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}
