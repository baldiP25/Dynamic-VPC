# VPC 
resource "aws_vpc" "ecomm-vpc" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "ecomm-vpc"
  }
}

# Subnet For Frontend
resource "aws_subnet" "ecomm-fe-subnet" {
  vpc_id     = aws_vpc.ecomm-vpc.id
  cidr_block = "192.168.0.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "ecomm-frontend-subnet"
  }
}

# Subnet For API/Backend
resource "aws_subnet" "ecomm-be-subnet" {
  vpc_id     = aws_vpc.ecomm-vpc.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "ecomm-backend-subnet"
  }
}

# Subnet For Database
resource "aws_subnet" "ecomm-db-subnet" {
  vpc_id     = aws_vpc.ecomm-vpc.id
  cidr_block = "192.168.2.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "ecomm-database-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "ecomm-igw" {
  vpc_id = aws_vpc.ecomm-vpc.id

  tags = {
    Name = "ecomm-internet-gateway"
  }
}

# Public Route Table
resource "aws_route_table" "ecomm-public-rt" {
  vpc_id = aws_vpc.ecomm-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecomm-igw.id
  }

  tags = {
    Name = "ecomm-public-routes"
  }
}

# Public Association Frontend
resource "aws_route_table_association" "ecomm-public-asc" {
  subnet_id      = aws_subnet.ecomm-fe-subnet.id
  route_table_id = aws_route_table.ecomm-public-rt.id
}

# Public Association Backend
resource "aws_route_table_association" "ecomm-public-asc-2" {
  subnet_id      = aws_subnet.ecomm-be-subnet.id
  route_table_id = aws_route_table.ecomm-public-rt.id
}

# Private Route Table
resource "aws_route_table" "ecomm-Private-rt" {
  vpc_id = aws_vpc.ecomm-vpc.id

  tags = {
    Name = "ecomm-private-routes"
  }
}

# Private Association Database
resource "aws_route_table_association" "ecomm-private-asc" {
  subnet_id      = aws_subnet.ecomm-db-subnet.id
  route_table_id = aws_route_table.ecomm-Private-rt.id
}

# NACL
resource "aws_network_acl" "ecomm-nacl" {
  vpc_id = aws_vpc.ecomm-vpc.id

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
    Name = "ecomm-nacl"
  }
}

# Secuirty Group Frontend
resource "aws_security_group" "ecomm-fe-sg" {
  name        = "ecomm-fe-sg"
  description = "Allow Frontend Traffic"
  vpc_id      = aws_vpc.ecomm-vpc.id

  tags = {
    Name = "ecomm-fe-sg"
  }
}

# SSH Rule
resource "aws_vpc_security_group_ingress_rule" "ecomm-fe-ssh" {
  security_group_id = aws_security_group.ecomm-fe-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# HTTP Rule
resource "aws_vpc_security_group_ingress_rule" "ecomm-fe-http" {
  security_group_id = aws_security_group.ecomm-fe-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# Egress / Outbound
resource "aws_vpc_security_group_egress_rule" "ecomm-fe-Outbound" {
  security_group_id = aws_security_group.ecomm-fe-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Secuirty Group Backend
resource "aws_security_group" "ecomm-be-sg" {
  name        = "ecomm-be-sg"
  description = "Allow Backend Traffic"
  vpc_id      = aws_vpc.ecomm-vpc.id

  tags = {
    Name = "ecomm-be-sg"
  }
}

# SSH Rule
resource "aws_vpc_security_group_ingress_rule" "ecomm-be-ssh" {
  security_group_id = aws_security_group.ecomm-be-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# HTTP Rule
resource "aws_vpc_security_group_ingress_rule" "ecomm-be-http" {
  security_group_id = aws_security_group.ecomm-be-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

# Egress / Outbound
resource "aws_vpc_security_group_egress_rule" "ecomm-be-Outbound" {
  security_group_id = aws_security_group.ecomm-be-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Secuirty Group Database
resource "aws_security_group" "ecomm-db-sg" {
  name        = "ecomm-db-sg"
  description = "Allow Database Traffic"
  vpc_id      = aws_vpc.ecomm-vpc.id

  tags = {
    Name = "ecomm-db-sg"
  }
}

# SSH Rule
resource "aws_vpc_security_group_ingress_rule" "ecomm-db-ssh" {
  security_group_id = aws_security_group.ecomm-db-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# HTTP Rule
resource "aws_vpc_security_group_ingress_rule" "ecomm-db-postgres" {
  security_group_id = aws_security_group.ecomm-db-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}

# Egress / Outbound
resource "aws_vpc_security_group_egress_rule" "ecomm-db-Outbound" {
  security_group_id = aws_security_group.ecomm-db-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}