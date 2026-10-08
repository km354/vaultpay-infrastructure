provider "aws" {
    region = "us-east-1"
}

module "vpc" {
    source = "./modules/vpc"

    project_name = var.project_name
    vpc_cidr = var.vpc_cidr
    public_subnet_cidrs = var.public_subnet_cidrs
    database_subnet_cidrs = var.database_subnet_cidrs
    app_subnet_cidrs = var.app_subnet_cidrs
}

module "database" {
    source = "./modules/database"

    project_name = var.project_name
    db_name = var.db_name
    db_username = var.db_username
    multi_az = var.multi_az
    backup_retention_period = var.backup_retention_period
    deletion_protection = var.deletion_protection
    skip_final_snapshot = var.skip_final_snapshot
    app_subnet_cidrs = var.app_subnet_cidrs
    vpc_id =  module.vpc.vpc_id
    db_subnet_ids = module.vpc.db_private_subnet_ids
}