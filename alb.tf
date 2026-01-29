# 1. ALB SECURITY GROUP
resource "aws_security_group" "alb_sg" {
  name   = "upgrad-alb-sg"
  vpc_id = aws_vpc.upgrad.id

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

  tags = {
    Name = "upgrad-alb-sg"
  }
}

# 2. ALB RESOURCE
resource "aws_lb" "upgrad_alb" {
  name               = "upgrad-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb_sg.id]

  subnets = [
    aws_subnet.public1.id,
    aws_subnet.public2.id
  ]

  tags = {
    Name = "upgrad-alb"
  }
}

# 3. TARGET GROUP: APPS (Private 1)
resource "aws_lb_target_group" "apps_tg" {
  name     = "apps-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.upgrad.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# 4. TARGET GROUP: JENKINS (Private 2)
resource "aws_lb_target_group" "jenkins_tg" {
  name     = "jenkins-tg"
  port     = 8080   # Jenkins service port
  protocol = "HTTP"
  vpc_id   = aws_vpc.upgrad.id

  health_check {
    path                = "/jenkins/login"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# 5. TARGET GROUP ATTACHMENTS

# Private 1 -> Apps TG (Port 80)
resource "aws_lb_target_group_attachment" "apps_attach" {
  target_group_arn = aws_lb_target_group.apps_tg.arn
  target_id        = aws_instance.private1_ec2.id
  port             = 80
}

# Private 2 -> Jenkins TG (Port 8080)
resource "aws_lb_target_group_attachment" "jenkins_attach" {
  target_group_arn = aws_lb_target_group.jenkins_tg.arn
  target_id        = aws_instance.private2_ec2.id
  port             = 8080
}

# 6. ALB LISTENER
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.upgrad_alb.arn
  port              = 80
  protocol          = "HTTP"

  # Default Action: Forward to Apps if no rules match
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.apps_tg.arn
  }
}

# 7. LISTENER RULES (PATH-BASED ROUTING)

# Rule for Jenkins (/jenkins*)
resource "aws_lb_listener_rule" "jenkins_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_tg.arn
  }

  condition {
    path_pattern {
      values = ["/jenkins*"]
    }
  }
}

# Rule for Apps (/apps*)
resource "aws_lb_listener_rule" "apps_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.apps_tg.arn
  }

  condition {
    path_pattern {
      values = ["/apps*"]
    }
  }
}