variable "vpc_id" {}

resource "aws_internet_gateway" "this" {
  vpc_id = var.vpc_id

  tags = {
    Name = "team-igw"
  }
}

output "igw_id" {
  value = aws_internet_gateway.this.id
}

