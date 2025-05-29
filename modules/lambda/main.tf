data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/sql_init.zip"
}

data "archive_file" "pymysql_layer_zip" {
  type        = "zip"
  source_dir  = "${path.module}/layer"
  output_path = "${path.module}/pymysql_layer.zip"
}

resource "aws_lambda_layer_version" "pymysql" {
  filename         = data.archive_file.pymysql_layer_zip.output_path
  layer_name       = "pymysql-layer"
  compatible_runtimes = ["python3.11"]
  source_code_hash = data.archive_file.pymysql_layer_zip.output_base64sha256
}

resource "aws_lambda_function" "sql_initializer" {
  function_name    = "rds-sql-initializer"
  role             = var.lambda_role_arn
  handler          = "main.lambda_handler"
  runtime          = "python3.11"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  layers = [
    aws_lambda_layer_version.pymysql.arn
  ]

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
