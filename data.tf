data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_ssm_parameter" "al2023_arn" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}