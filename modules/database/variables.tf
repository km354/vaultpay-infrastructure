variable "project_name" {
  description = "project name used for resource"
  type        = string
}

variable "db_name" {
  description = "the database name"
  type        = string
}

variable "db_username" {
  description = "the username of the database"
  type        = string
}

variable "multi_az" {
  description = "Whether to deploy the RDS instance to a single or multi AZ"
  type        = bool
}

variable "backup_retention_period" {
  description = "The amount of days the rds retention backups will have"
  type        = number
}

variable "deletion_protection" {
  description = "Whether the RDS instance can be deleted or not"
  type        = bool
}

variable "skip_final_snapshot" {
  description = "Whether you can skip or not skip the final snapshot"
  type        = bool
}

variable "app_sg_id" {
  description = "the id of the apps security group"
  type        = string
}

variable "db_subnet_ids" {
  description = "all of the database subnet ids"
  type        = list(string)
}

variable "vpc_id" {
  description = "the id of the main vpc"
  type        = string
}