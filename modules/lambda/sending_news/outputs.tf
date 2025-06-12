output "lambda_arn" {
  description = "Lambda 함수의 ARN"
  value       = aws_lambda_function.this.arn
}

output "function_name" {
  description = "Lambda 함수의 이름"
  value       = aws_lambda_function.this.function_name
}

output "invoke_arn" {
  description = "Lambda 함수의 Invoke ARN"
  value       = aws_lambda_function.this.invoke_arn
}

output "lambda_function_name" {
  value = aws_lambda_function.this.function_name
}

output "lambda_function_arn" {
  value = aws_lambda_function.this.arn
}