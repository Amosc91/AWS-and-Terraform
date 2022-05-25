resource "aws_instance" "web" {
  count                       = var.webs_instances_count
  ami                         = data.aws_ami.Ubuntu.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.DMZ.*.id[count.index]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.nginx_allow_http_ssh.id]
  user_data                   = local.user_data

  root_block_device {
    encrypted   = false
    volume_type = var.volumes_type
    volume_size = var.webs_root_disk_size
  }

  ebs_block_device {
    encrypted   = true
    device_name = var.web_encrypted_disk_device_name
    volume_type = var.volumes_type
    volume_size = var.web_encrypted_disk_size
  }
  tags = {
    "Name" = "nginx-web-${regex(".$", data.aws_availability_zones.available.names[count.index])}"
  }

}