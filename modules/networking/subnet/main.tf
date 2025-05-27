variable "vpc_id" {
  type = string
}

resource "aws_subnet" "public_1a" {
  vpc_id                  = var.vpc_id
  cidr_block              = "192.168.1.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true
  tags = {
    "Name"                                = "public-subnet-1a"
    "kubernetes.io/role/elb"              = "1"
    "kubernetes.io/cluster/news-cluster"  = "shared"
  }
}

resource "aws_subnet" "public_2c" {
  vpc_id                  = var.vpc_id
  cidr_block              = "192.168.2.0/24"
  availability_zone       = "ap-northeast-2c"
  map_public_ip_on_launch = true
  tags = {
    "Name"                                = "public-subnet-2c"
    "kubernetes.io/role/elb"              = "1"
    "kubernetes.io/cluster/news-cluster"  = "shared"
  }
}

resource "aws_subnet" "private_3b" {
  vpc_id            = var.vpc_id
  cidr_block        = "192.168.3.0/24"
  availability_zone = "ap-northeast-2b"
  tags = {
    "Name"                                = "private-subnet-3b"
    "kubernetes.io/role/internal-elb"     = "1"
    "kubernetes.io/cluster/news-cluster"  = "shared"
  }
}

resource "aws_subnet" "private_4d" {
  vpc_id            = var.vpc_id
  cidr_block        = "192.168.4.0/24"
  availability_zone = "ap-northeast-2d"
  tags = {
    "Name"                                = "private-subnet-4d"
    "kubernetes.io/role/internal-elb"     = "1"
    "kubernetes.io/cluster/news-cluster"  = "shared"
  }
}

output "public_subnet_ids" {
  value = [
    aws_subnet.public_1a.id,
    aws_subnet.public_2c.id
  ]
}

output "private_subnet_ids" {
  value = [
    aws_subnet.private_3b.id,
    aws_subnet.private_4d.id
  ]
}
