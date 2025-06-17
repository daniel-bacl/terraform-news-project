provider "aws" {
  region = "ap-northeast-2"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.30"
    }
    grafana = {
      source  = "grafana/grafana"
      version = ">= 2.11"
    }
  }
}