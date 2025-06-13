resource "aws_lambda_function" "news-crawler_mw" {
  function_name = "news-crawler-lambda"
  package_type  = "Image"
  image_uri     = var.docker_image_uri
  role          = var.lambda_exec_role_arn
  timeout       = 180
  memory_size   = 1024

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.rds_sg_id]
  }

  environment {
    variables = {
      DB_HOST     = var.rds_endpoint
      DB_PORT     = var.rds_port
      DB_NAME     = var.rds_db_name
      DB_USER     = var.rds_username
      DB_PASSWORD = var.db_password
    }
  }
}