# 기존 news_layer 유지 (직접 압축한 zip 사용 시)
resource "aws_lambda_layer_version" "news_layer" {
  filename             = "${path.module}/../lambda_layer.zip"
  layer_name           = "news_layer"
  compatible_runtimes  = ["python3.11"]
  source_code_hash     = filebase64sha256("${path.module}/../lambda_layer.zip")
}

# pymysql_layer 를 archive_file 방식으로 정의
data "archive_file" "pymysql_layer" {
  type        = "zip"
  source_dir  = "${path.module}/zipforder"
  output_path = "${path.module}/pymysql_layer.zip"
}

resource "aws_lambda_layer_version" "pymysql" {
  filename             = data.archive_file.pymysql_layer.output_path
  layer_name           = "pymysql-layer"
  compatible_runtimes  = ["python3.11"]
  source_code_hash     = data.archive_file.pymysql_layer.output_base64sha256
}

output "pymysql_layer_arn" {
  value = aws_lambda_layer_version.pymysql.arn
}