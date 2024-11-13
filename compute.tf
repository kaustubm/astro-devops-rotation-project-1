# Launch Template for Web Tier
resource "aws_launch_template" "web" {
  name_prefix   = "${var.app_name}-web-"
  image_id      = "ami-0df7a207adb9748c7" # Amazon Linux 2 AMI in ap-southeast-1
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              # Install CloudWatch agent
              yum install -y amazon-cloudwatch-agent
              /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:AmazonCloudWatch-Config
              EOF
  )

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.app_name}-web"
      Environment = var.environment
      Tier        = "web"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Launch Template for Application Tier
resource "aws_launch_template" "app" {
  name_prefix   = "${var.app_name}-app-"
  image_id      = "ami-0df7a207adb9748c7" # Amazon Linux 2 AMI in ap-southeast-1
  instance_type = "t3.small"

  network_interfaces {
    security_groups = [aws_security_group.app.id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.app_profile.name
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y java-11-amazon-corretto
              # Install CloudWatch agent
              yum install -y amazon-cloudwatch-agent
              /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:AmazonCloudWatch-Config
              EOF
  )

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.app_name}-app"
      Environment = var.environment
      Tier        = "app"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group for Web Tier
resource "aws_autoscaling_group" "web" {
  name                      = "${var.app_name}-web-asg"
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 1
  target_group_arns         = [aws_lb_target_group.web.arn]
  vpc_zone_identifier       = aws_subnet.public[*].id
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.app_name}-web"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group for Application Tier
resource "aws_autoscaling_group" "app" {
  name                      = "${var.app_name}-app-asg"
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 1
  target_group_arns         = [aws_lb_target_group.app.arn]
  vpc_zone_identifier       = aws_subnet.private_app[*].id
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.app_name}-app"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
