resource "aws_db_subnet_group" "main" {
  name       = "vaultpay-db-subnet-group"
  subnet_ids = var.db_subnet_ids
  tags = {
    Name    = "${var.project_name}-db-subnet-group"
    Project = var.project_name
  }
}

resource "aws_security_group" "db_sg" {
  name   = "${var.project_name}-db-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-db-sg"
    Project = var.project_name
  }
}

resource "aws_db_instance" "db_1" {
  db_name                     = var.db_name
  engine                      = "postgres"
  engine_version              = "18"
  instance_class              = "db.t3.micro"
  storage_type                = "gp3"
  allocated_storage           = 20
  identifier                  = "db-vaultpay"
  db_subnet_group_name        = aws_db_subnet_group.main.name
  username                    = var.db_username
  manage_master_user_password = true
  storage_encrypted           = true
  vpc_security_group_ids      = [aws_security_group.db_sg.id]
  publicly_accessible         = false
  multi_az                    = var.multi_az
  skip_final_snapshot         = var.skip_final_snapshot
  final_snapshot_identifier   = var.skip_final_snapshot ? null : "prod-db-final-snapshot"
  backup_retention_period     = var.backup_retention_period
  deletion_protection         = var.deletion_protection

  tags = {
    Name    = "${var.project_name}-db-instance-1"
    Project = var.project_name
  }
}

