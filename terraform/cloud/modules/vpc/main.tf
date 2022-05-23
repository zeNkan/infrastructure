provider "aws" {
  region = var.region
}

resource "aws_vpc" "main_vpc" {
  cidr_block       = var.vpc_cidr_range
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_name
  }
}

# Create a default security for the vpc
resource "aws_security_group" "default" {
  name        = "${var.vpc_name}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.main_vpc.id
  depends_on  = [aws_vpc.main_vpc]

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }
}

## PRIVATE SUBNETS
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main_vpc.id
  count                   = length(var.priv_subnets)
  cidr_block              = element(var.priv_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.vpc_name}-${element(var.availability_zones, count.index)}-private"
  }
}

# Private NAT Gateways
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.private.*.id, 0)
  depends_on    = [aws_internet_gateway.main_igw]
  tags = {
    Name = "${var.vpc_name}-nat"
  }
}

resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.main_igw]
}

# Private subnets route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.vpc_name}-private-route-table"
  }
}

# Add route for private route table to nat gateway
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.priv_subnets)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

## PUBLIC SUBNETS
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main_vpc.id
  count                   = length(var.pub_subnets)
  cidr_block              = element(var.pub_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-${element(var.availability_zones, count.index)}-public"
  }
}

# Create the main internet gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# Public subnets route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.vpc_name}-public-route-table"
  }
}

# Add route for public route table to internet gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main_igw.id
}

# Associate the public route table to public subnets
resource "aws_route_table_association" "public" {
  count          = length(var.pub_subnets)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}
