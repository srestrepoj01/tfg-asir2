resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}

resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet("10.0.0.0/16", 8, count.index)
  availability_zone       = element(["eu-west-3a", "eu-west-3b", "eu-west-3c"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project_name}-public-${count.index}"
    Project = var.project_name
  }
}

resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet("10.0.0.0/16", 8, count.index + 3)
  availability_zone = element(["eu-west-3a", "eu-west-3b", "eu-west-3c"], count.index)

  tags = {
    Name    = "${var.project_name}-private-${count.index}"
    Project = var.project_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-public-rt"
    Project = var.project_name
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID de la VPC"
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "Lista de IDs de subredes publicas"
}

output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "Lista de IDs de subredes privadas"
}
