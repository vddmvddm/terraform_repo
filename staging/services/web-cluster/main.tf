provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "terraform-storage-bucket-mars"
    key            = "staging/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#output "public_ip" {
#  value       = aws_instance.example.public_ip
#  description = "The public IP address of the web server1"
#}

resource "aws_launch_template" "launch_template" {
  name_prefix            = "launch_template_1"
  image_id               = "ami-0708a0921e5eaf65d"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]
  key_name               = "test"
  tags = {
    Name = "terr LT"
  }
}

resource "aws_autoscaling_group" "first_asg" {
  name                = "ASG"
  vpc_zone_identifier = ["subnet-58a5733e", "subnet-89e086c4"]
  min_size            = 1
  max_size            = 2
  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }
}

resource "aws_elb" "terr_elb" {
  name               = "terraform-lb"
  availability_zones = ["us-east-1a", "us-east-1c"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 20
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_elb" {
  autoscaling_group_name = aws_autoscaling_group.first_asg.id
  elb                    = aws_elb.terr_elb.id
}
