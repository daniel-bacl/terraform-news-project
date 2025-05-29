variable "public_subnet_id" {
  type = string
}

resource "aws_eip" "nat_eip" {
      domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = var.public_subnet_id

  tags = {
    Name = "nat-gateway"
  }
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat.id
}

