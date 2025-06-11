output "rds_endpoint" {
  value = aws_db_instance.this.address
}

output "rds_identifier" {
  value = aws_db_instance.this.identifier
}

output "rds_username" {
  value = var.username
}

output "rds_password" {
  value = var.password
}

output "rds_database_name" {
  value = var.db_name
}