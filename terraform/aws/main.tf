provider "aws" {
  region = var.aws_region
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

# MINECRAFT SETUP

resource "aws_s3_bucket" "mc_backup" {
  bucket = "lanbros-mc-backup"
  acl    = "private"

  lifecycle_rule {
    id      = "mc_backup_expiration"
    enabled = true

    expiration {
      days = "7"
    }
  }
}

resource "aws_iam_user" "mc_backup" {
  name = "mc-backup"
}

data "aws_iam_policy_document" "mc_backup_policy_doc" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.mc_backup.arn}/*",
    ]
  }

  statement {
    actions = [
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.mc_backup.arn
    ]
  }
}

resource "aws_iam_user_policy" "mc_backup_policy" {
  name   = "mc_backup_policy"
  user   = aws_iam_user.mc_backup.name
  policy = data.aws_iam_policy_document.mc_backup_policy_doc.json
}

// TESTING
resource "aws_iam_user" "test_user" {
  name = "test-user"
}

resource "aws_s3_bucket" "test_bucket" {
  bucket = "backla-test"
  acl    = "private"
}

data "aws_iam_policy_document" "test_policy_doc" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.test_bucket.arn}/*",
    ]
  }

  statement {
    actions = [
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.mc_backup.arn
    ]
  }
}

resource "aws_iam_user_policy" "test_policy" {
  name   = "mc_backup_policy"
  user   = aws_iam_user.test_user.name
  policy = data.aws_iam_policy_document.test_policy_doc.json
}

