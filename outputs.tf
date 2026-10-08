output "vpc_id" {
    description = "the id of the vpc"
    value = module.vpc.vpc_id
}

output "public_subnet_ids" {
    description = "all of the public subnet ids"
    value = module.vpc.public_subnet_ids
}

output "app_private_subnet_ids" {
    description = "all of the app subnet ids"
    value = module.vpc.app_private_subnet_ids
}

output "db_private_subnet_ids" {
    description = "all of the db subnet ids"
    value = module.vpc.db_private_subnet_ids
}

output "alb_dns_name" {
    description = "the dns name of the alb"
    value = aws_lb.vaultpay_alb.dns_name
}