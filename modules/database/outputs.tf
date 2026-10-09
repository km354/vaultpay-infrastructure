output "db_endpoint" {
  description = "the RDS instance endpoint"
  value       = aws_db_instance.db_1.endpoint
}

output "db_port" {
  description = "the port that the db is on"
  value       = aws_db_instance.db_1.port
}

output "db_name" {
  description = "the name of the RDS instance"
  value       = aws_db_instance.db_1.db_name
}

output "db_security_group_id" {
  description = "the id of the database security group"
  value       = aws_security_group.db_sg.id
}

output "db_master_secret_arn" {
  description = "the arn of the master secret password"
  value       = aws_db_instance.db_1.master_user_secret[0].secret_arn
}