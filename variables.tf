variable "vpc_cidr" {
    description = "the cidr block of the vpc"
    type = string
}

variable "public_subnet_cidrs" {
    description = "all of the public subnet cidr blocks"
    type = list(string)
}

variable "database_subnet_cidrs" {
    description = "all of the cidr block for the database subnets"
    type = list(string)
}

variable "app_subnet_cidrs" {
    description = "all of the cidr blocks for the app subnets"
    type = list(string)
}

variable "project_name" {
    description = "project name used for resource"
    type = string
}
