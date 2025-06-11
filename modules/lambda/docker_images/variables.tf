variable "docker_image_uri" {
  description = "ECR Docker Image URI"
  type        = string
}

variable "db_password" {
  description = "RDS root password"
  type        = string
  sensitive   = true
}
