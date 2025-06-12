variable "docker_image_uri" {
  description = "ECR Docker Image URI"
  type        = string
}

variable "lambda_exec_role_arn" {
  description = "IAM role ARN for Lambda execution"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for Lambda"
  type        = list(string)
}

variable "rds_sg_id" {
  description = "Security Group ID for RDS access"
  type        = string
}

variable "rds_endpoint" {
  description = "RDS endpoint"
  type        = string
}

variable "rds_port" {
  description = "RDS port"
  type        = string
}

variable "rds_username" {
  description = "RDS username"
  type        = string
}

variable "rds_db_name" {
  description = "RDS database name"
  type        = string
}

variable "db_password" {
  description = "RDS password"
  type        = string
  sensitive   = true
}