output "lambda_function_name" {
  value = aws_lambda_function.news-crawler_mw.function_name
}

output "lambda_function_arn" {
  value = aws_lambda_function.news-crawler_mw.arn
}