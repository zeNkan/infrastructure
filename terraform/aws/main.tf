provider "aws" {
  region = var.aws_region
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Define the main VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = var.packer_build_vpc_cidr

  tags = {
    Name = "main-vpc"
  }
}

# Create the main internet gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.packer_build_env}-igw"
  }
}

# Create the subnet
resource "aws_subnet" "packer_build_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.packer_build_vpc_cidr
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.packer_build_env}-pub-subnet"
    Environment = "${var.packer_build_env}"
  }
}

# Create a routing table in our VPC
# Creates a default route to our internet gateway
resource "aws_route_table" "packer_build_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.main_igw.id
  }
}

# Associate routing table with our new subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.packer_build_subnet.id
  route_table_id = aws_route_table.packer_build_rt.id
}

# Create a security group for packer
resource "aws_security_group" "default" {
  name        = "${var.packer_build_env}-sg"
  description = "SSH access for packer to build and provision ami"
  vpc_id      = aws_vpc.main_vpc.id
  depends_on  = [aws_vpc.main_vpc]

  # Allow SSH ingress
  ingress {
    from_port = "22"
    to_port   = "22"
    # As defined in the definition of IpProtocol:
    # https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_IpPermission.html
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all output traffic
  egress {
    from_port = "0"
    to_port   = "0"
    # As defined in the definition of IpProtocol:
    # https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_IpPermission.html
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.packer_build_env}-sg"
  }
}

module "minecraft-backup" {
  source = "./modules/minecraft-backup/"
  username = "mc-backup"
}


module "minecraft-status" {
  source = "./modules/minecraft-status/"
  ecr_repo_name = "minecraft-status"
  prefix = "minecraft-status"
  image_tag = "latest"
}

module "cloudflare_cert" { 
  source = "./modules/cloudflare_verified_cert/"

  hostname = "ms"
  domain_name = "backman.fyi"
}

module "api_gateway" {
  source = "./modules/api_gateway/"
  hostname = "ms"
  lambda_name = module.minecraft-status.lambda_name
  lambda_arn = module.minecraft-status.lambda_arn
  zone_name = "backman.fyi"
  cert_arn = module.cloudflare_cert.arn
}

