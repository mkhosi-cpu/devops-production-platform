# ============================================================================
# Week 2 network, expressed as Terraform. Resources reference each other by
# logical name (e.g. aws_vpc.lab.id), which also defines create/destroy order.
# ============================================================================

# ---- VPC ----
resource "aws_vpc" "lab" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true # enabled in Week 2 for the interface endpoints
  tags                 = { Name = "devops-lab-vpc" }
}

# ---- Subnets (2 public, 2 private, across 2 AZs) ----
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true # enabled in Week 3
  tags                    = { Name = "public-a" }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags                    = { Name = "public-b" }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.lab.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-east-1a"
  tags              = { Name = "private-a" }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.lab.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1b"
  tags              = { Name = "private-b" }
}

# ---- Internet Gateway ----
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.lab.id
  tags   = { Name = "devops-lab-igw" }
}

# ---- Route tables ----
# Public: default route to the internet via the IGW.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "public-rt" }
}

# Private: no internet route. The S3 prefix-list route is owned by the S3
# endpoint below (via route_table_ids), so we ignore route drift here.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.lab.id
  tags   = { Name = "private-rt" }

  lifecycle {
    ignore_changes = [route] # the S3 gateway endpoint manages a route here
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

# ---- Security groups ----
resource "aws_security_group" "alb" {
  name        = "devops-lab-alb-sg"
  description = "HTTPS from internet to load balancer"
  vpc_id      = aws_vpc.lab.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "devops-lab-alb-sg" }
}

resource "aws_security_group" "app" {
  name        = "devops-lab-app-sg"
  description = "App port from ALB SG only"
  vpc_id      = aws_vpc.lab.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "devops-lab-app-sg" }
}

resource "aws_security_group" "admin" {
  name        = "devops-lab-admin-sg"
  description = "Admin access via SSM; no inbound"
  vpc_id      = aws_vpc.lab.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "devops-lab-admin-sg" }
}

# ---- S3 Gateway endpoint (free controlled egress for private subnets) ----
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.lab.id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]
  tags              = { Name = "devops-lab-s3-endpoint" }
}
