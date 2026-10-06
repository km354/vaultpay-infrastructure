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

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "vaultpay-igw"
        Project = "VaultPay"
    }
}

resource "aws_eip" "nat_eip_a" {
    domain = "vpc"

    tags = {
        Name = "vaultpay-eip-nat-a"
        Project = "VaultPay"
    }
}

resource "aws_nat_gateway" "nat_a" {
    allocation_id = aws_eip.nat_eip_a.id
    subnet_id = aws_subnet.public_a.id

    tags = {
        Name = "vaultpay-nat-gwy"
        Project = "VaultPay"
    }

    depends_on = [aws_internet_gateway.main]
}

resource "aws_subnet" "public_a" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidrs[0]
    availability_zone = "us-east-1a"

    tags = {
        Name = "vaultpay-public-subnet-a"
        Project = "VaultPay"
    }

}


resource "aws_subnet" "public_b" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidrs[1]
    availability_zone = "us-east-1b"

     tags = {
        Name = "vaultpay-public-subnet-b"
        Project = "VaultPay"
    }

}


resource "aws_subnet" "app_a" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.app_subnet_cidrs[0]
    availability_zone = "us-east-1a"

    tags = {
        Name = "vaultpay-app-subnet-a"
        Project = "VaultPay"
    }

}

resource "aws_subnet" "app_b" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.app_subnet_cidrs[1]
    availability_zone = "us-east-1b"

    tags = {
        Name = "vaultpay-app-subnet-b"
        Project = "VaultPay"
    }

}

resource "aws_subnet" "db_a" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.database_subnet_cidrs[0]
    availability_zone = "us-east-1a"

    tags = {
        Name = "vaultpay-database-subnet-a"
        Project = "VaultPay"
    }

}

resource "aws_subnet" "db_b" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.database_subnet_cidrs[1]
    availability_zone = "us-east-1b"

    tags = {
        Name = "vaultpay-database-subnet-b"
        Project = "VaultPay"
    }

}

resource "aws_route_table" "public_rt" {
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

resource "aws_route_table" "app_rt" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_a.id
    }

    tags = {
        Name = "vaultpay-app-rt"
        Project = "VaultPay"
    }
}

resource "aws_route_table" "db_rt" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "vaultpay-database-rt"
        Project = "VaultPay"
    }
}

resource "aws_route_table_association" "public_rt_a" {
    route_table_id = aws_route_table.public_rt.id
    subnet_id = aws_subnet.public_a.id

}

resource "aws_route_table_association" "public_rt_b" {
    route_table_id = aws_route_table.public_rt.id
    subnet_id = aws_subnet.public_b.id

}

resource "aws_route_table_association" "app_rt_a" {
    route_table_id = aws_route_table.app_rt.id
    subnet_id = aws_subnet.app_a.id
}

resource "aws_route_table_association" "app_rt_b" {
    route_table_id = aws_route_table.app_rt.id
    subnet_id = aws_subnet.app_b.id
}

resource "aws_route_table_association" "db_rt_a" {
    route_table_id = aws_route_table.db_rt.id
    subnet_id = aws_subnet.db_a.id
}

resource "aws_route_table_association" "db_rt_b" {
    route_table_id = aws_route_table.db_rt.id
    subnet_id = aws_subnet.db_b.id
}