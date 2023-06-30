##############
## Provider ##
##############

provider "aws" {
  profile = "terraform"
  region  = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

##################
## EC2 Instance ##
##################

resource "aws_instance" "web" {
  ami           = 
  instance_type = "t2.micro"
  key_name = 

  tags = {
    Name = "web-server"
  }
}

######################
## Cloudwatch Alarm ##
######################

resource "aws_cloudwatch_metric_alarm" "demo-alarm" {
  alarm_name          = "demo-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []

  dimensions = {
    InstanceId = aws_instance.web.id
  }
  alarm_actions     = []
}

