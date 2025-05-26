resource "aws_vpc" "main" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "team-vpc"
  }
}

output "vpc_id" {
  value = aws_vpc.main.id
}
