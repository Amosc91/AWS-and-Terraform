resource "aws_lb" "web_nginx" {
  name               = "nginx-alb-${aws_vpc.GrWh-web.id}"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.DMZ.*.id
  security_groups    = [aws_security_group.nginx_allow_http_ssh.id]

  tags = {
    "Name" = "nginx-alb-${aws_vpc.GrWh-web.id}"
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
  vpc_id   = aws_vpc.GrWh-web.id

  health_check {
    enabled = true
    path    = "/"
  }

  tags = {
    "Name" = "nginx-target-group-${aws_vpc.GrWh-web.id}"
  }
}

resource "aws_lb_target_group_attachment" "web-server" {
  count            = 2
  target_group_arn = aws_lb_target_group.web_nginx.id
  target_id        = aws_instance.web.*.id[count.index]
  port             = 80
}