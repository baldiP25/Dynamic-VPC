# VPC 
resource "aws_vpc" "login-vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = var.vpc_tenancy

  tags = {
    Name = var.vpc_name
  }
}

# Public Subnets
resource "aws_subnet" "public_subnets" {
  vpc_id     = aws_vpc.login-vpc.id
  for_each   = var.public_subnet_cidrs
  cidr_block = each.value
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "${var.vpc_name}-${each.key}-subnet"
  }
}

# Subnet For Database
resource "aws_subnet" "login-db-subnet" {
  vpc_id     = aws_vpc.login-vpc.id
  cidr_block = var.private_subnet_cidr
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "${var.vpc_name}-database-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "login-igw" {
  vpc_id = aws_vpc.login-vpc.id

  tags = {
    Name = "${var.vpc_name}-internet-gateway"
  }
}

# Public Route Table
resource "aws_route_table" "login-public-rt" {
  vpc_id = aws_vpc.login-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.login-igw.id
  }

  tags = {
    Name = "${var.vpc_name}-public-routes"
  }
}

# Private Route Table
resource "aws_route_table" "login-Private-rt" {
  vpc_id = aws_vpc.login-vpc.id

  tags = {
    Name = "${var.vpc_name}-private-routes"
  }
}

# Public Subnets Association Frontend
resource "aws_route_table_association" "login-public-asc" {
  for_each       = var.public_subnet_cidrs
  subnet_id      = aws_subnet.public_subnets[each.key].id
  route_table_id = aws_route_table.login-public-rt.id
}

# Private Association Database
resource "aws_route_table_association" "login-private-asc" {
  subnet_id      = aws_subnet.login-db-subnet.id
  route_table_id = aws_route_table.login-Private-rt.id
}

# NACL
resource "aws_network_acl" "login-nacl" {
  vpc_id = aws_vpc.login-vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/00"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/00"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "${var.vpc_name}-nacl"
  }
}

# Secuirty Group Frontend
resource "aws_security_group" "login-fe-sg" {
  name        = "login-fe-sg"
  description = "Allow Frontend Traffic"
  vpc_id      = aws_vpc.login-vpc.id

  tags = {
    Name = "${var.vpc_name}-fe-sg"
  }
}

# Secuirty Group Rules FE Ports
resource "aws_vpc_security_group_ingress_rule" "login-web-ingress" {
  count = length(var.web_ingress_ports)
  security_group_id = aws_security_group.login-fe-sg.id
  cidr_ipv4         = var.web_ingress_ports[count.index].cidr
  from_port         = var.web_ingress_ports[count.index].port
  ip_protocol       = "tcp"
  to_port           = var.web_ingress_ports[count.index].port
}

# Secuirty Group Backend
resource "aws_security_group" "login-app-sg" {
  name        = "login-app-sg"
  description = "Allow Backend Traffic"
  vpc_id      = aws_vpc.login-vpc.id

  tags = {
    Name = "${var.vpc_name}-be-sg"
  }
}

# Secuirty Group Rules BE Ports
resource "aws_vpc_security_group_ingress_rule" "login-app-ingress" {
  count = length(var.app_ingress_ports)
  security_group_id = aws_security_group.login-app-sg.id
  cidr_ipv4         = var.app_ingress_ports[count.index].cidr
  from_port         = var.app_ingress_ports[count.index].port
  ip_protocol       = "tcp"
  to_port           = var.app_ingress_ports[count.index].port
}

# Secuirty Group Database
resource "aws_security_group" "login-db-sg" {
  name        = "login-db-sg"
  description = "Allow Database Traffic"
  vpc_id      = aws_vpc.login-vpc.id

  tags = {
    Name = "${var.vpc_name}-db-sg"
  }
}

# Secuirty Group Rules DB Ports
resource "aws_vpc_security_group_ingress_rule" "login-db-ingress" {
  count = length(var.db_ingress_ports)
  security_group_id = aws_security_group.login-db-sg.id
  cidr_ipv4         = var.db_ingress_ports[count.index].cidr
  from_port         = var.db_ingress_ports[count.index].port
  ip_protocol       = "tcp"
  to_port           = var.db_ingress_ports[count.index].port
}

# Locals for easier access
locals {
  secuirty_groups = {
    web = aws_security_group.login-fe-sg.id
    app = aws_security_group.login-app-sg.id
    db  = aws_security_group.login-db-sg.id
  }
}

resource "aws_vpc_security_group_egress_rule" "common_egress" {
  for_each = local.secuirty_groups
  security_group_id = each.value
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}