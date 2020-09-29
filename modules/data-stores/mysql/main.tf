resource "aws_db_instance" "example" {
  identifier_prefix = "terraform-up-and-running"
  engine            = "mysql"
  allocated_storage = 10
  instance_class    = "db.t2.micro"
  name              = var.db_name
  username          = "admin"
  # Как нам задать пароль?
  password = var.db_password
}
