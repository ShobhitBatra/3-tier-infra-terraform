# Creating app-alb means application load balancer for the app
resource "aws_lb" "alb_web" {
  name               = "alb-web"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.sg_alb.id]
  subnets = [
    aws_subnet.subnet_public_infra_a.id,
    aws_subnet.subnet_public_infra_b.id
  ]
}

# Create listener for ALB (attaching target group to the ALB via a listener)
resource "aws_lb_listener" "alb_listener_web" {
  load_balancer_arn = aws_lb.alb_web.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg_web.arn
  }
}

# Creating target group for an ALB
resource "aws_lb_target_group" "alb_tg_web" {
  name        = "alb-tg-web"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc_main.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Registering EC2 instances in target group
resource "aws_lb_target_group_attachment" "alb_tga_web" {
  for_each = {
    web1 = aws_instance.ec2_web_a.id
    web2 = aws_instance.ec2_web_b.id
  }
  target_group_arn = aws_lb_target_group.alb_tg_web.arn
  target_id        = each.value
  port             = 80
}
