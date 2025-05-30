data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}"
  output_path = "${path.module}/sql_init.zip"
}

resource "aws_lambda_function" "sql_initializer" {
  function_name    = "rds-sql-initializer"
  role             = var.lambda_role_arn
  handler          = "main.lambda_handler"
  runtime          = "python3.11"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  layers = [var.pymysql_layer_arn]

  environment {
    variables = {
      DB_HOST     = var.db_host
      DB_USER     = var.db_user
      DB_PASSWORD = var.db_password
      DB_NAME     = var.db_name
      DB_PORT     = var.db_port
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }
}
