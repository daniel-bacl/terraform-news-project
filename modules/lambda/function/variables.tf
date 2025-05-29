variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
}

variable "role_arn" {
  description = "Lambda execution role ARN"
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