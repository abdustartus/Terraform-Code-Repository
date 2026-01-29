# Ubuntu AMI
variable "ubuntu_ami" {
  default = "ami-0fc5d935ebf8bc3bc" # Example Ubuntu 20.04 us-east-1
}

variable "instance_type" {
  default = "t3.small"
}

# User Data for Public Instance
locals {
  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install apache2 -y
              systemctl start apache2
              systemctl enable apache2
              echo "<h1>Server $(hostname)</h1>" > /var/www/html/index.html
              EOF
}

# Public Instance (Bastion/Utility)
resource "aws_instance" "public_ec2" {
  ami                         = var.ubuntu_ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public1.id
  vpc_security_group_ids       = [aws_security_group.public_sg.id]
  key_name                     = aws_key_pair.upgrad_key.key_name
  associate_public_ip_address = true
  user_data                   = local.user_data

  tags = {
    Name = "upgrad-public-ec2"
  }
}

# Private Instance 1 (Apps Server)
resource "aws_instance" "private1_ec2" {
  ami                    = var.ubuntu_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private1.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = aws_key_pair.upgrad_key.key_name
  user_data              = local.user_data
  
  # Added for ECR Access (Sub-task 4)
  iam_instance_profile   = aws_iam_instance_profile.ec2_ecr_profile.name
  
  tags = {
    Name = "upgrad-private1-ec2"
  }
}

# Private Instance 2 (Jenkins Server)
resource "aws_instance" "private2_ec2" {
  ami                    = var.ubuntu_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private2.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = aws_key_pair.upgrad_key.key_name
  user_data              = local.user_data
  
  # Added for ECR Access (Sub-task 4)
  iam_instance_profile   = aws_iam_instance_profile.ec2_ecr_profile.name

  tags = {
    Name = "upgrad-private2-ec2"
  }
}