data "archive_file" "pymysql_layer" {
  type        = "zip"
  source_dir  = "${path.module}/zipfolder"
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
