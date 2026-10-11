# -----------------------------------------
# Discover Availability Zones
# -----------------------------------------
data "aws_availability_zones" "available" {
  state = "available"
}

# -----------------------------------------
# Select first two Availability Zones
# -----------------------------------------

locals {
  azs = var.availability_zones

  subnet_config = {
    public = {
      for index, az in local.azs : az => {
        cidr = cidrsubnet(var.vpc_cidr, 8, index)
        az   = az
      }
    }

    private_app = {
      for index, az in local.azs : az => {
        cidr = cidrsubnet(var.vpc_cidr, 8, 10 + index)
        az   = az
      }
    }

    private_db = {
      for index, az in local.azs : az => {
        cidr = cidrsubnet(var.vpc_cidr, 8, 20 + index)
        az   = az
      }
    }
  }

  public_subnets      = local.subnet_config.public
  private_app_subnets = local.subnet_config.private_app
  private_db_subnets  = local.subnet_config.private_db
}

# --------------------------------------------------
# VPC
# --------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# --------------------------------------------------
# Internet Gateway
# --------------------------------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# --------------------------------------------------
# Public Subnets
# --------------------------------------------------

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-public-${each.key}"
    Tier = "public"
  }
}

# --------------------------------------------------
# Private Application Subnets
# --------------------------------------------------

resource "aws_subnet" "private_app" {
  for_each = local.private_app_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-app-${each.key}"
    Tier = "private-app"
  }
}

# --------------------------------------------------
# Private Database Subnets
# --------------------------------------------------

resource "aws_subnet" "private_db" {
  for_each = local.private_db_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-db-${each.key}"
    Tier = "private-db"
  }
}

# --------------------------------------------------
# Public Route Table
# --------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# --------------------------------------------------
# Private Application Route Tables
# --------------------------------------------------

resource "aws_route_table" "private_app" {
  for_each = local.private_app_subnets

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-app-rt-${each.key}"
  }
}

resource "aws_route_table_association" "private_app" {
  for_each = aws_subnet.private_app

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_app[each.key].id
}

# --------------------------------------------------
# Private Database Route Tables
# --------------------------------------------------

resource "aws_route_table" "private_db" {
  for_each = local.private_db_subnets

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-db-rt-${each.key}"
  }
}

resource "aws_route_table_association" "private_db" {
  for_each = aws_subnet.private_db

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_db[each.key].id
}
