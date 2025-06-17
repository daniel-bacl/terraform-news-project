variable "lambda_schedules" {
  description = "다중 Lambda 스케줄링 매핑"
  type = map(object({
    schedule_expression = string
    lambda_function_name = string
    lambda_function_arn  = string
    target_id            = string
  }))
}