provider "aws" {
  region = "us-east-1"
}
resource "aws_db_instance" "example" {
  identifier_prefix = "terraform-up-and-running"
  engine            = "mysql"
  allocated_storage = 10
  instance_class    = "db.t2.micro"
  name              = "example_database"
  username          = "admin"
  # Как нам задать пароль?
  password = "data.aws_secretsmanager_secret_version.db_password.secret_string"
}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "terraform_testing_DB"
}
