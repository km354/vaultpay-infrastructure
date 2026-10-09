output "vpc_id" {
  description = "the id of the vpc"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "all of the public subnet ids"
  value       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

output "app_private_subnet_ids" {
  description = "all of the app subnet ids"
  value       = [aws_subnet.app_a.id, aws_subnet.app_b.id]
}

output "db_private_subnet_ids" {
  description = "all of the db subnet ids"
  value       = [aws_subnet.db_a.id, aws_subnet.db_b.id]
}