terraform {
  backend "s3" {
    bucket         = "soldesk-news-project-bk"
    key            = "env/dev/terraform.tfstate"
    region         = "ap-northeast-2"
    use_lock_table = true
  }
}
