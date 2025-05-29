# --------------------------------------------
# Lambda 함수 zip 파일 생성 (자동으로 .zip 생성)
# --------------------------------------------
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

# --------------------------------------------
# Lambda CloudWatch 로그 그룹
# --------------------------------------------
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14

  tags = {
    Name = "Lambda Log Group"
  }
}

# --------------------------------------------
# Lambda 함수 리소스
# --------------------------------------------
resource "aws_lambda_function" "this" {
  function_name = var.lambda_function_name
  role          = var.role_arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  layers = [var.layer_arn]

  environment {
    variables = var.environment
  }

  depends_on = [aws_cloudwatch_log_group.lambda_logs]
}
