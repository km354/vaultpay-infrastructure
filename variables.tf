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

variable "db_name" {
    description = "the database name"
    type = string
}

variable "db_username" {
    description = "the username of the database"
    type = string
}

variable "multi_az" {
    description = "Whether to deploy the RDS instance to a single or multi AZ"
    type = bool
}

variable "backup_retention_period" {
    description = "The amount of days the rds retention backups will have"
    type = number
}

variable "deletion_protection" {
    description = "Whether the RDS instance can be deleted or not"
    type = bool
}

variable "skip_final_snapshot" {
    description = "Whether you can skip or not skip the final snapshot"
    type = bool
}

variable "force_delete_ecr" {
    description = "Whether or not to enforce delete protection for ecr"
    type = bool
}

variable "force_delete_s3" {
    description = "Whether or not to enforce delete protection for s3"
    type = bool
}
