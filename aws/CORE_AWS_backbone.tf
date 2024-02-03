provider "aws" {
  region = "us-east-2" # Change this to your desired AWS region
}

# Creating 5 VPCs
resource "aws_vpc" "main" {
  count = 5

  cidr_block           = "10.${count.index}.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "VPC-${count.index}"
  }
}

# Creating Internet Gateways for each VPC
resource "aws_internet_gateway" "gw" {
  count = 5

  vpc_id = aws_vpc.main[count.index].id

  tags = {
    Name = "IGW-VPC-${count.index}"
  }
}

# Creating external subnets for each VPC
resource "aws_subnet" "external" {
  count = 5 # 5 VPCs, each with 1 external subnet

  vpc_id                  = aws_vpc.main[count.index].id
  cidr_block              = "10.${count.index}.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "External-Subnet-VPC-${count.index}"
  }
}

# Creating a route table for each VPC and associating with the external subnet
resource "aws_route_table" "rt" {
  count = 5

  vpc_id = aws_vpc.main[count.index].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw[count.index].id
  }

  tags = {
    Name = "RT-VPC-${count.index}"
  }
}

resource "aws_route_table_association" "rta" {
  count = 5

  subnet_id      = aws_subnet.external[count.index].id
  route_table_id = aws_route_table.rt[count.index].id
}

# Creating internal subnets for each VPC
resource "aws_subnet" "internal" {
  count = 5 # 5 VPCs, each with 1 internal subnet

  vpc_id     = aws_vpc.main[count.index].id
  cidr_block = "10.${count.index}.1.0/24"

  tags = {
    Name = "Internal-Subnet-VPC-${count.index}"
  }
}

# Creating DMZ subnets for each VPC
resource "aws_subnet" "dmz" {
  count = 5 # 5 VPCs, each with 1 DMZ subnet

  vpc_id     = aws_vpc.main[count.index].id
  cidr_block = "10.${count.index}.2.0/24"

  tags = {
    Name = "DMZ-Subnet-VPC-${count.index}"
  }
}
