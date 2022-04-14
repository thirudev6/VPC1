provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIAUM2NLS2VOU33HSX6"
  secret_key = "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"
}
resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.1/16"
  instance_tenancy = "default"

  tags = {
    Name = "my-vpc"
  }
}
resource "aws_subnet" "pub" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public"
  }
}
resource "aws_subnet" "pri" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.1.0.0/24"

  tags = {
    Name = "private"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw"
  }
}
resource "aws_eip" "lb" {
    vpc      = true
  }
  resource "aws_nat_gateway" "ngw" {
    allocation_id = aws_eip.lb.id
    subnet_id     = aws_subnet.lb.id
  
    tags = {
      Name = "gw NAT"
    }
    resource "aws_route_table" "rt1" {
        vpc_id = aws_vpc.vpc.id
      
    route {
          cidr_block = "0.0.0.0/0"
          gateway_id = aws_internet_gateway.gw.id
    }
     tags = {
       Name = "custom rt"
    }
    resource "aws_route_table" "rt2" {
        vpc_id = aws_vpc.vpc.id
      
    route {
          cidr_block = "0.0.0.0/0"
          gateway_id = aws_nat_gateway.ngw.id
    }
     tags = {
       Name = "main rt"
    }
    
    resource "aws_route_table_association" "route2" {
        subnet_id      = aws_subnet.pri.id
        route_table_id = aws_route_table.rt2.id
      }

    resource "aws_security_group" "sg" {
        name        = "first-sg"
        description = "Allow TLS inbound traffic"
        vpc_id      = aws_vpc.vpc.id
      
        ingress {
          description      = "TLS from VPC"
          from_port        = 22
          to_port          = 22
          protocol         = "tcp"
          cidr_blocks      = [aws_vpc.vpc.cidr_block]
        }
      
        egress {
          from_port        = 0
          to_port          = 0
          protocol         = "-1"
          cidr_blocks      = ["0.0.0.0/0"]
        }
      
        tags = {
          Name = "first-sg"
        }
      }
      
