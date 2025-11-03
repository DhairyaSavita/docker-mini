# 1. Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 2. Key Pair (Used for SSH access)
resource "aws_key_pair" "devops_key" {
  key_name   = var.key_name
  public_key = file("/Users/${split("/", pathexpand("~"))[2]}/.ssh/id_rsa.pub")
}

# 3. Security Group (Firewall Rules)
resource "aws_security_group" "web_sg" {
  name        = "web-app-sg"
  description = "Allow SSH and HTTP traffic"

  ingress {
    description = "SSH access from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP access from anywhere (Web App)"
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

  tags = {
    Name = "DevOps-Web-SG"
  }
}

# 4. EC2 Instance (The Server)
resource "aws_instance" "web_server" {
  ami           = "ami-0c02fb55956c7d316"  # Ubuntu 22.04 LTS in us-east-1
  instance_type = var.instance_type
  key_name      = aws_key_pair.devops_key.key_name
  
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              EOF

  tags = {
    Name = "DevOps-CI-CD-Web-Server"
  }
}