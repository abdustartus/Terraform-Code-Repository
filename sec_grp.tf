# Fetch self public IP dynamically
data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

locals {
  my_ip = "${chomp(data.http.myip.response_body)}/32"
}

# 1. PUBLIC SECURITY GROUP (Bastion & ALB Entry) 
resource "aws_security_group" "public_sg" {
  # Using name_prefix instead of name to avoid dependency locks
  name_prefix = "public-sg-" 
  description = "Public SG: SSH from self IP, HTTP open"
  vpc_id      = aws_vpc.upgrad.id

  # SSH - only from your specific local IP
  ingress {
    description = "SSH from self IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip]
  }

  # HTTP - open for the world to hit the ALB
  ingress {
    description = "HTTP from anywhere"
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

  lifecycle {
    create_before_destroy = true
  }

  tags = { Name = "public-sg" }
}

# 2. PRIVATE SECURITY GROUP (Apps & Jenkins)
resource "aws_security_group" "private_sg" {
  # Using name_prefix instead of name to avoid dependency locks
  name_prefix = "private-sg-"
  description = "Private SG: access only from public SG and ALB"
  vpc_id      = aws_vpc.upgrad.id

  # SSH - Access from Bastion
  ingress {
    description     = "SSH from public instances and internal VPC"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
    cidr_blocks     = ["172.16.0.0/16"]
  }

  # HTTP (Port 80) - Traffic for Apps
  ingress {
    description     = "HTTP access from ALB for Apps"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] 
  }

  # Jenkins (Port 8080) - Traffic from ALB and Bastion
  ingress {
    description     = "Jenkins access from ALB and Bastion"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [
      aws_security_group.public_sg.id,
      aws_security_group.alb_sg.id
    ]
  }

  # ICMP (Ping) - Debugging
  ingress {
    description = "Allow Ping from within VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["172.16.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = { Name = "private-sg" }
}