

# --- VPC Creation ---
resource "aws_vpc" "ecs_dev_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name        = var.vpc_name_tag
    Environment = var.environment
  }
}


# --- Public Subnets ---
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.ecs_dev_vpc.id
  cidr_block              = var.public_subnet_cidr_blocks[0]
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags = {
    Name        = var.public_subnet_names[0]
    Tier        = "Public"
    Environment = var.environment
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.ecs_dev_vpc.id
  cidr_block              = var.public_subnet_cidr_blocks[1]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags = {
    Name        = var.public_subnet_names[0]
    Tier        = "Public"
    Environment = var.environment
  }
}

# --- Private Subnets ---
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.ecs_dev_vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[0]
  availability_zone = var.availability_zones[2]
  tags = {
    Name        = var.private_subnet_names[0]
    Tier        = "Private"
    Environment = var.environment
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.ecs_dev_vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[1]
  availability_zone = var.availability_zones[1]
  tags = {
    Name        = var.private_subnet_names[1]
    Tier        = "Private"
    Environment = var.environment
  }
}

# --- Internet Gateway ---
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.ecs_dev_vpc.id

  tags = {
    Name        = var.internet_gateway_name
    Environment = var.environment
  }
}

# --- Elastic IP and NAT Gateway ---
resource "aws_eip" "nat_eip" {
  depends_on = [aws_internet_gateway.gw]

  tags = {
    Name        = var.nat_eip_name
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name        = var.nat_gateway_name
    Environment = var.environment
  }

  depends_on = [aws_eip.nat_eip]
}


# --- Route Tables ---
# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ecs_dev_vpc.id

  route {
    cidr_block = var.public_route_cidr_block
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name        = var.public_route_table_name
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.ecs_dev_vpc.id

  route {
    cidr_block     = var.private_route_cidr_block
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name        = var.private_route_table_name
    Environment = var.environment
  }
}

resource "aws_route_table_association" "private_assoc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}
