provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./modules/vpc"

  project_name          = var.project_name
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  app_subnet_cidrs      = var.app_subnet_cidrs
}

module "database" {
  source = "./modules/database"

  project_name            = var.project_name
  vpc_id                  = module.vpc.vpc_id
  db_subnet_ids           = module.vpc.db_private_subnet_ids
  app_sg_id               = aws_security_group.app_sg.id
  db_name                 = var.db_name
  db_username             = var.db_username
  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
}

module "application" {
  source = "./modules/application"

  project_name           = var.project_name
  vpc_id                 = module.vpc.vpc_id
  public_subnet_ids      = module.vpc.public_subnet_ids
  app_private_subnet_ids = module.vpc.app_private_subnet_ids
  app_sg_id              = aws_security_group.app_sg.id
  db_master_secret_arn   = module.database.db_master_secret_arn
  db_endpoint            = module.database.db_endpoint
  db_port                = module.database.db_port
  db_name                = module.database.db_name
  force_delete_ecr       = var.force_delete_ecr
  force_delete_s3        = var.force_delete_s3
  image_tag              = var.image_tag
}


resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-app-sg"
  description = "Allow HTTP from the ALB"
  vpc_id      = module.vpc.vpc_id

  egress {
    description = "all outbound for secrets manager, ECR, RDS, etc via NAT"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-app-sg"
    Project = var.project_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_ingress" {
  security_group_id            = aws_security_group.app_sg.id
  referenced_security_group_id = module.application.alb_security_group_id

  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}