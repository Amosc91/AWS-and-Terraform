resource "aws_instance" "DB" {
  count                       = var.DB_instances_count
  ami                         = data.aws_ami.Ubuntu.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.DB.*.id[count.index]
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.db_allow_ssh.id]

  tags = {
    "Name" = "DB-${regex(".$", data.aws_availability_zones.available.names[count.index])}"
  }
}