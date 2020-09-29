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
module "mysql" {
  source      = "../../../modules/data-stores/mysql"
  db_name     = "productiondb"
  db_password = "ThisIsMySecuredCode!"
}
