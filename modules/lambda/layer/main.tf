resource "aws_lambda_layer_version" "news_layer" {
  filename            = "${path.module}/../lambda_layer.zip"
  layer_name          = "news_layer"
  compatible_runtimes = ["python3.10"]
  source_code_hash    = filebase64sha256("${path.module}/../lambda_layer.zip")
}
