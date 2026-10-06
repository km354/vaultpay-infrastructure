provider "aws" {
    region = "us-east-1"
}

resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr

    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "vaultpay-vpc"
        Project = "Vaultpay"
    }
}

resource "aws_subnet" "public_a" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidr[0]
    availability_zone = "us-east-1a"

    tags = {
        Name = "vaultpay-public-subnet-a"
        Project = "VaultPay"
    }

}


resource "aws_subnet" "public_b" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidr[1]
    availability_zone = "us-east-1b"

     tags = {
        Name = "vaultpay-public-subnet-b"
        Project = "VaultPay"
    }
    
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "vaultpay-igw"
        Project = "VaultPay"
    }
}

resource "aws_route_table" "public_subnet_rt" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0" 
        gateway_id = aws_internet_gateway.main.id
    }

    tags =  {
        Name = "vaultpay-public-rt"
        Project = "VaultPay"
    }
}

resource "aws_route_table_association" "rt_association_pb_a" {
    route_table_id = aws_route_table.public_subnet_rt.id
    subnet_id = aws_subnet.public_a.id

}

resource "aws_route_table_association" "rt_association_pb_b" {
    route_table_id = aws_route_table.public_subnet_rt.id
    subnet_id = aws_subnet.public_b.id

}