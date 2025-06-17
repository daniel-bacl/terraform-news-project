terraform {
  backend "s3" {
    bucket         = "soldesk-news-project-bk"
    key            = "env/dev/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}
