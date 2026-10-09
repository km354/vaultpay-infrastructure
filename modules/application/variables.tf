variable "project_name" {
  description = "project name used for resource"
  type        = string
}

variable "force_delete_ecr" {
  description = "Whether or not to enforce delete protection for ecr"
  type        = bool
  default     = false
}

variable "force_delete_s3" {
  description = "Whether or not to enforce delete protection for s3"
  type        = bool
  default     = false
}

variable "image_tag" {
  description = "Container image tag to deploy"
  type        = string
  default     = "latest"
}

variable "app_sg_id" {
  description = "the id of the applications security group"
  type        = string
}

variable "vpc_id" {
  description = "the id of the main vpc"
  type        = string
}

variable "db_master_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the RDS master credentials. The instance role is scoped to read only this secret."
  type        = string
}

variable "public_subnet_ids" {
  description = "A list of public subnet IDs for the ALB."
  type        = list(string)
}

variable "app_private_subnet_ids" {
  description = "A list of app-private subnet IDs for the Auto Scaling Group."
  type        = list(string)
}

variable "db_endpoint" {
  description = "RDS endpoint in 'host:port' form. The module extracts the host and passes it to the container."
  type        = string
}

variable "db_port" {
  description = "Port number for the RDS instance."
  type        = number
}

variable "db_name" {
  description = "Name of the PostgreSQL database inside RDS."
  type        = string
}