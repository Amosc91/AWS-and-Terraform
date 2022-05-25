#nginx
resource "aws_security_group" "nginx_allow_http_ssh" {
  name   = "nginx_allow_http_ssh"
  vpc_id = module.vpc_module.vpc_id

  tags = {
    Name = "nginx_allow_http_ssh-${module.vpc_module.vpc_id}"
  }
}

resource "aws_security_group_rule" "nginx_http_access" {
  description       = "Allow HTTP access from anywhere"
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.nginx_allow_http_ssh.id
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "nginx_ssh_access" {
  description       = "Allow SSH access from anywhere"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.nginx_allow_http_ssh.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "nginx_outbound_anywhere" {
  description       = "Allow outbound to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.nginx_allow_http_ssh.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
#DB
resource "aws_security_group" "db_allow_ssh" {
  name   = "db_allow_ssh"
  vpc_id = module.vpc_module.vpc_id

  tags = {
    Name = "db_allow_http_ssh-${module.vpc_module.vpc_id}"
  }
}

resource "aws_security_group_rule" "db_ssh_access" {
  description       = "Allow SSH access from anywhere"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.db_allow_ssh.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "db_nginx_outbound_anywhere" {
  description       = "Allow outbound to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.db_allow_ssh.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}