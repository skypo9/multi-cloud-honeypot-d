provider "aws" {
    region = "us-east-1"
  }
  
  # Use the latest Ubuntu 22.04 LTS AMI for us-east-1
  data "aws_ami" "ubuntu" {
    most_recent = true
    owners      = ["099720109477"] # Canonical (Ubuntu publisher)
  
    filter {
      name   = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
  }
  
  resource "aws_instance" "cowrie_aws" {
    ami           = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    key_name      = "csec5615"  # Replace with your actual key name
  
    user_data = file("cowrie-setup.sh")
  
    vpc_security_group_ids = [aws_security_group.cowrie_sg.id]
  
    tags = {
      Name = "cowrie-aws"
    }
  }
  
  resource "aws_security_group" "cowrie_sg" {
    name = "cowrie_sg"
  
    description = "Security group for Cowrie honeypot"
  
    ingress {
      description = "Admin SSH Access to Cowrie honeypot"
      from_port   = 22222
      to_port     = 22222
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  
    ingress {
      description = "Honeypot service ports (22-23)"
      from_port   = 22
      to_port     = 23
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
  