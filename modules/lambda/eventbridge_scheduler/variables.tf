variable "lambda_schedules" {
  type = map(object({
    description          = optional(string)
    schedule_expression  = string
    lambda_function_name = string
    lambda_function_arn  = string
    target_id            = string
  }))
}