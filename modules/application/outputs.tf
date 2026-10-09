output "ecr_repository_url" {
  description = "the ecr repositories url"
  value       = aws_ecr_repository.vaultpay.repository_url
}

output "app_bucket_name" {
  description = "the name of the bucket used for logs when the website is up"
  value       = aws_s3_bucket.app_bucket.id
}

output "alb_dns_name" {
  description = "the dns name of the load balancer"
  value       = aws_lb.vaultpay_alb.dns_name
}

output "alb_security_group_id" {
  description = "the id of the application load balancer security group id"
  value       = aws_security_group.alb_sg.id
}
