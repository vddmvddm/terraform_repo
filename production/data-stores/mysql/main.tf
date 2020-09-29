terraform {
  backend "s3" {
    bucket         = "terraform-storage-bucket-mars"
    key            = "production/mysql/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_secretsmanager_secret_version" "creds" {
  # Fill in the name you gave to your secret
  secret_id = "eb-creds"
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
}

module "mysql" {
  source      = "../../../modules/data-stores/mysql"
  db_name     = "productiondb"
  db_password = local.db_creds.password
}
