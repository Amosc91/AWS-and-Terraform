data "aws_ami" "Ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}
resource "aws_instance" "web" {
  count = 2
  ami           = data.aws_ami.Ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = "subnet-0e473f6143443da0d"

  tags = {
    Name    = "Grandpa'sWhiskeyWeb-${count.index}"
    Owner   = "Amos"
    Purpose = "Whiskey"
  }
user_data = <<-EOF
#! /bin/bash
sudo apt-get update
sudo apt-get install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
echo "<h1>"Welcome to Grandpa's Whiskey"<h1>" | sudo tee /var/www/html/index.html
EOF
}

resource "aws_volume_attachment" "ebs_att" {
  count = 2
  device_name = "/dev/sdh"
  instance_id = aws_instance.web[count.index].id
  volume_id   = aws_ebs_volume.non-root[count.index].id
}

resource "aws_ebs_volume" "non-root" {
  count = 2
  availability_zone = "us-east-1b"
  size              = 10
  encrypted = true
}

resource "aws_security_group" "web_allow_http" {
  name        = "web_allow_http"
  description = "Allow http inbound traffic"

  ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http"
  }
}