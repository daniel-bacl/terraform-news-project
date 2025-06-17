variable "cluster_name" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "account_id" {
  type = string
}

variable "oidc_provider_url" {
  type = string
  description = "OIDC provider URL without https://"
}
