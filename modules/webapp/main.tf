data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["137112412989"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_lb" "this" {
  name               = "web-alb"
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.alb_subnet_ids
}

resource "aws_lb_target_group" "http" {
  name     = "tg-http"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = "/"
    matcher             = "200-399"
    healthy_threshold   = 2
    unhealthy_threshold = 5
    interval            = 30
    timeout             = 5
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}

resource "aws_iam_role" "ec2" {
  name = "webapp-ec2-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{ Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "this" {
  name = "webapp-ec2-profile"
  role = aws_iam_role.ec2.name
}

locals {
  user_data = <<-EOT
    #!/bin/bash
    dnf update -y
    dnf install -y nginx
    systemctl enable nginx
    echo "<h1>${var.instance_type} - $(date)</h1>" > /usr/share/nginx/html/index.html
    systemctl start nginx
  EOT
}

resource "aws_launch_template" "this" {
  name_prefix   = "webapp-lt-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type
  key_name      = var.keypair_name

  iam_instance_profile { name = aws_iam_instance_profile.this.name }

  network_interfaces {
    security_groups = [var.app_sg_id]
  }

  user_data = base64encode(local.user_data)
}

resource "aws_autoscaling_group" "this" {
  name                      = "webapp-asg"
  desired_capacity          = var.desired_capacity
  min_size                  = var.min_size
  max_size                  = var.max_size
  vpc_zone_identifier       = var.app_subnet_ids
  health_check_type         = "EC2"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.http.arn]

  lifecycle {
    create_before_destroy = true
  }
}
