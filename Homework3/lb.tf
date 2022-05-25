resource "aws_lb" "web_nginx" {
  name               = "nginx-alb-${module.vpc_module.vpc_id}"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc_module.public_subnets_id
  security_groups    = [aws_security_group.nginx_allow_http_ssh.id]

  tags = {
    "Name" = "nginx-alb-${module.vpc_module.vpc_id}"
  }
}

resource "aws_lb_listener" "web_nginx" {
  load_balancer_arn = aws_lb.web_nginx.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_nginx.arn
  }
}

resource "aws_lb_target_group" "web_nginx" {
  name     = "nginx-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc_module.vpc_id

  health_check {
    enabled = true
    path    = "/"
  }

  tags = {
    "Name" = "nginx-target-group-${module.vpc_module.vpc_id}"
  }
}

resource "aws_lb_target_group_attachment" "web-server" {
  count            = 2
  target_group_arn = aws_lb_target_group.web_nginx.id
  target_id        = aws_instance.web.*.id[count.index]
  port             = 80
}