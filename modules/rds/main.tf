resource "aws_db_subnet_group" "this" {
  name       = var.name
  subnet_ids = var.subnet_ids

  tags = {
    Name = var.name
  }
}

resource "aws_db_parameter_group" "timezone" {
  name        = "${var.name}-timezone"
  family      = "mysql8.0"

  parameter {
    name  = "time_zone"
    value = "Asia/Seoul"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }
}

resource "aws_db_instance" "this" {
  identifier              = var.name
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  username                = var.username
  password                = var.password
  db_name                 = var.db_name
  publicly_accessible     = false
  multi_az                = true
  storage_encrypted       = false
  skip_final_snapshot     = true
  deletion_protection     = false
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = var.security_group_ids
  parameter_group_name    = aws_db_parameter_group.timezone.name

  tags = {
    Name = var.name
  }

  depends_on = [
    aws_db_parameter_group.timezone,
    aws_db_subnet_group.this
  ]
}
