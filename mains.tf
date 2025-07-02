provider "aws" {
    region = "ap-south-1"
}

resource "aws_instance" "ec2_instance_for_DevOps_task"{
ami = "ami-0d03cb826412c6b0f"
instance_type = "t2.micro"
subnet_id = aws_subnet.devops_subnet.id
vpc_security_group_ids = [aws_security_group.devops_vpc_securitygateway.id]
associate_public_ip_address = true

tags = {
        Name = "ec2-created-from-terraform"
}


user_data = <<-EOF
  #!/bin/bash
  yum update -y
  yum install -y httpd
  mkdir -p /var/www/html
  cat <<EOT > /var/www/html/index.html
  <!DOCTYPE html>
  <html lang="en">
  <head>
      <meta charset="UTF-8">
      <title>Hello from DevOps_XOps</title>
      <style>
          body {
              background-position: center;
              color: white;
          }
          h1 {
              background-color: rgba(0, 0, 0, 0.5);
              padding: 20px;          }
      </style>
  </head>
  <body>
      <h1>🚀!! Hello from XOps !!🚀</h1>
  </body>
  </html>
  EOT
  systemctl start httpd
  systemctl enable httpd
EOF
}

resource "aws_vpc" "devops_vpc" {
  cidr_block = "10.10.0.0/16"
}

resource "aws_subnet" "devops_subnet" {
  vpc_id     = aws_vpc.devops_vpc.id
  cidr_block = "10.10.1.0/24"

  tags = {
    Name = "devops_vpc"
  }
}

resource "aws_internet_gateway" "devops_internetgateway" {
  vpc_id = aws_vpc.devops_vpc.id

  tags = {
    Name = "devops_internetgateway"
  }
}

resource "aws_route_table" "devops_routetable" {
  vpc_id = aws_vpc.devops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops_internetgateway.id
  }

  tags = {
    Name = "devops_routetable"
  }
}

resource "aws_route_table_association" "devops_routetableassociation" {
  subnet_id      = aws_subnet.devops_subnet.id
  route_table_id = aws_route_table.devops_routetable.id
}

resource "aws_security_group" "devops_vpc_securitygateway" {
  name        = "devops_vpc_securitygateway"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.devops_vpc.id

  tags = {
    Name = "devops_securitygateway"
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}