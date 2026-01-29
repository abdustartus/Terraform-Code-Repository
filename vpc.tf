# 1. VPC Configuration
resource "aws_vpc" "upgrad" {
  cidr_block = "172.16.0.0/16"
  tags       = { Name = "upgrad" }
}

# 2. Public Subnet (Required for the NAT Gateway to connect to the IGW for internet access)
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.upgrad.id
  cidr_block              = "172.16.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags                    = { Name = "public1" }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.upgrad.id
  cidr_block              = "172.16.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = { Name = "public2" }
}


# 3. Private Subnets (Defined in Multi AZs in us-east-1 region)
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.upgrad.id
  cidr_block        = "172.16.2.0/24"
  availability_zone = "us-east-1a"
  tags              = { Name = "private1" }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.upgrad.id
  cidr_block        = "172.16.3.0/24"
  availability_zone = "us-east-1b"
  tags              = { Name = "private2" }
}

# 4. Internet Gateway (IGW)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.upgrad.id
  tags   = { Name = "upgrad-igw" }
}

# 5. NAT Gateway (NGW)
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public1.id # Must be in the PUBLIC subnet
  depends_on    = [aws_internet_gateway.igw]
  tags          = { Name = "upgrad-nat" }
}

# 6. Route Tables
# Public Route Table (Connects Public Subnet to Internet)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.upgrad.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Private Route Table (Connects Private Subnets to NAT Gateway)
resource "aws_route_table" "pvt_rt" {
  vpc_id = aws_vpc.upgrad.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }
}

# 7. Associations
resource "aws_route_table_association" "pub_assoc" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "pub_assoc2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_route_table_association" "pvt_assoc1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.pvt_rt.id
}

resource "aws_route_table_association" "pvt_assoc2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.pvt_rt.id
}