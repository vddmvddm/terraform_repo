resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-sg"
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

resource "aws_launch_configuration" "example" {
  image_id        = "ami-0f40c8f97004632f9"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance.id]
  user_data       = data.template_file.user_data.rendered

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "terr_lb" {
  name               = "application-load-balancer"
  load_balancer_type = "application"
  subnets            = ["subnet-58a5733e", "subnet-89e086c4"]
  security_groups    = [aws_security_group.instance.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.terr_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100
  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asgtg.arn
  }
}

resource "aws_lb_target_group" "asgtg" {
  name     = "target-1"
  port     = "8080"
  protocol = "HTTP"
  vpc_id   = "vpc-8d9d7ff0"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier  = ["subnet-58a5733e", "subnet-89e086c4"]

  target_group_arns = [aws_lb_target_group.asgtg.arn]
  health_check_type = "ELB"

  min_size = var.min_size
  max_size = var.max_size

  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true
  }
}

data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = var.db_remote_state_bucket
    key    = var.db_remote_state_key
    region = "us-east-1"
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")

  vars = {
    server_port = var.server_port
    db_address  = data.terraform_remote_state.db.outputs.address
    #db_address = "echo1"
    db_port = data.terraform_remote_state.db.outputs.port
    #db_port = "echo2"
  }
}
