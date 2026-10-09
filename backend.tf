terraform {
  backend "s3" {
    bucket = "state-terraform-bucket-413724559977-us-east-1-an"
    key    = "vaultpay/terraform.tfstate"
    region = "us-east-1"

    use_lockfile = true
    encrypt      = true
  }
}