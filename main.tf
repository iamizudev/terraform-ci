# 1. Tell Terraform to use the AWS provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# 2. Configure the AWS Provider and target region
provider "aws" {
  region = "eu-west-1" 
}

# 3. Create the Virtual Private Cloud (VPC)
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16" # Defines the IP address range for the network
  enable_dns_hostnames = true

  tags = {
    Name = "simple-ci-vpc"
    Environment = "Learning"
  }
}

# 4. Create a Public Subnet inside our VPC
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24" # A slice of the VPC IP range
  map_public_ip_on_launch = true          # Gives resources in this subnet a public IP

  tags = {
    Name = "simple-public-subnet"
    Environment = "Learning"
  }
}

# 5. Create an Internet Gateway so the VPC can talk to the internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "simple-internet-gateway"
    Environment = "Learning"
  }
}

# 6. Create a Route Table to direct traffic to the Internet Gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0" # Represents all internet traffic
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
    Environment = "Learning"
  }
}

# 7. Explicitly link our Subnet to the Route Table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
