provider "aws" {
  region = "us-east-1"
}


resource "aws_instance" "example" {
  ami                    = "ami-0f82752aa17ff8f5d"
  instance_type          = "t2.micro"
  user_data              = <<-EOF
  #!/bin/bash
  echo "Hello, World" > index.html
  nohup busybox httpd -f -p 8080 &
  EOF
  vpc_security_group_ids = [aws_security_group.instance.id]
  tags = {
    Name = "terrform-example"
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
}

output "public_ip" {
  value       = aws_instance.example.public_ip
  description = "The public IP address of the web server1"
}
