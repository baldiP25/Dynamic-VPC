# Variables

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

# Variable VPC CIDR
variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

# Variable VPC Tenancy
variable "vpc_tenancy" {
  type = string
  default = "default"
}

# Variable VPC Name
variable "vpc_name" {
  type = string
  default = "login"
}

# Variable Public Subnets
variable "public_subnet_cidrs" {
  type = map(string)
  default = {
    frontend = "10.0.0.0/24"
    backend = "10.0.1.0/24" 
  }
}

# Variable Private Subnets
variable "private_subnet_cidr" {
  type = string
  default = "10.0.2.0/24"
}

# Variable FE Ports
variable "web_ingress_ports" {
  description = "Ports Allowed"
  type        = list(object({
    port  = number
    cidr  = string
  }))
  default = [
    { port = 22, cidr = "0.0.0.0/0"},
    { port = 80, cidr = "0.0.0.0/0"}
  ]
}  

# Variable BE Ports
variable "app_ingress_ports" {
  description = "Ports Allowed"
  type        = list(object({
    port  = number
    cidr  = string
  }))
  default = [
    { port = 22, cidr = "0.0.0.0/0"},
    { port = 8080, cidr = "0.0.0.0/0"}
  ]
}  

# Variable BE Ports
variable "db_ingress_ports" {
  description = "Ports Allowed"
  type        = list(object({
    port  = number
    cidr  = string
  }))
  default = [
    { port = 22, cidr = "0.0.0.0/0"},
    { port = 5432, cidr = "0.0.0.0/0"}
  ]
}