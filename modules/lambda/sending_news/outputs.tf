# Lambda 함수 ARN (CloudWatch Event 등에서 사용 가능)
output "lambda_arn" {
  description = "Lambda 함수의 ARN"
  value       = aws_lambda_function.this.arn
}

# Lambda 함수 이름 (IAM Permission 등에서 사용 가능)
output "function_name" {
  description = "Lambda 함수의 이름"
  value       = aws_lambda_function.this.function_name
}

# Lambda Invoke ARN (API Gateway 등에서 직접 호출 시 사용 가능)
output "invoke_arn" {
  description = "Lambda 함수의 Invoke ARN"
  value       = aws_lambda_function.this.invoke_arn
}
