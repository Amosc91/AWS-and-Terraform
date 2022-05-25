resource "aws_vpc" "GrWh-web" {
  cidr_block       = var.vpc_cider_block
  instance_tenancy = "default"

  tags = {
    "Name" = "GrWh-web_VPC"
  }
}

resource "aws_subnet" "DMZ" {
  count             = length(var.public_subnet)
  cidr_block        = var.public_subnet[count.index]
  vpc_id            = aws_vpc.GrWh-web.id
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    "Name" = "Public_subnet_${regex(".$", data.aws_availability_zones.available.names[count.index])}_${aws_vpc.GrWh-web.id}"
  }
}

resource "aws_subnet" "DB" {
  count             = length(var.private_subnet)
  cidr_block        = var.private_subnet[count.index]
  vpc_id            = aws_vpc.GrWh-web.id
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    "Name" = "Private_subnet_${regex(".$", data.aws_availability_zones.available.names[count.index])}_${aws_vpc.GrWh-web.id}"
  }
}

resource "aws_internet_gateway" "InternetGW" {
  vpc_id = aws_vpc.GrWh-web.id

  tags = {
    name = "mainGW"
  }
}

resource "aws_eip" "eip" {
  count = length(var.public_subnet)
  tags = {
    "Name" = "NAT_elastic_ip_${regex(".$", data.aws_availability_zones.available.names[count.index])}_${aws_vpc.GrWh-web.id}"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.public_subnet)
  allocation_id = aws_eip.eip.*.id[count.index]
  subnet_id     = aws_subnet.DMZ.*.id[count.index]

  tags = {
    "Name" = "NAT_${regex(".$", data.aws_availability_zones.available.names[count.index])}_${aws_vpc.GrWh-web.id}"
  }
}

resource "aws_route_table" "route_tables" {
  count  = length(var.route_tables_names)
  vpc_id = aws_vpc.GrWh-web.id

  tags = {
    "Name" = "${var.route_tables_names[count.index]}_RTB_${aws_vpc.GrWh-web.id}"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet)
  route_table_id = aws_route_table.route_tables[0].id
  subnet_id      = aws_subnet.DMZ.*.id[count.index]
}
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet)
  route_table_id = aws_route_table.route_tables[count.index + 1].id
  subnet_id      = aws_subnet.DB.*.id[count.index]
}

resource "aws_route" "DMZ" {
  route_table_id         = aws_route_table.route_tables[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.InternetGW.id
}

resource "aws_route" "DB" {
  count                  = length(var.private_subnet)
  route_table_id         = aws_route_table.route_tables.*.id[count.index + 1]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.*.id[count.index]
}