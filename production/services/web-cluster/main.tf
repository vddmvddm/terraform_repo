terraform {
  backend "s3" {
    bucket         = "terraform-storage-bucket-mars"
    key            = "production/web-cluster/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

module "web-cluster" {
  source                 = "../../../modules/services/web-cluster"
  cluster_name           = "web-cluster-production"
  db_remote_state_bucket = "terraform-storage-bucket-mars"
  db_remote_state_key    = "production/mysql/terraform.tfstate"
  instance_type          = "t2.micro"
  min_size               = 2
  max_size               = 2
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  scheduled_action_name  = "scale-out-during-business-hours"
  min_size               = 2
  max_size               = 10
  desired_capacity       = 10
  recurrence             = "0 9 * * *"
  autoscaling_group_name = module.web-cluster.asg_name
}
resource "aws_autoscaling_schedule" "scale_in_at_night" {
  scheduled_action_name  = "scale-in-at-night"
  min_size               = 2
  max_size               = 10
  desired_capacity       = 2
  recurrence             = "0 17 * * *"
  autoscaling_group_name = module.web-cluster.asg_name
}
