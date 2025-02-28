terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}

# Use IAM roles instead of hardcoded credentials
provider "aws" {
  region = "us-east-1"
}

# IAM Role for EC2
resource "aws_iam_role" "amcal_ec2_role" {
  name = "amcal_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for the EC2 Role
resource "aws_iam_policy" "amcal_ec2_policy" {
  name        = "amcal_ec2_policy"
  description = "Policy for EC2 instances"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket", "ec2:DescribeInstances"]
        Resource = "*"
      }
    ]
  })
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "amcal_ec2_role_attach" {
  policy_arn = aws_iam_policy.amcal_ec2_policy.arn
  role       = aws_iam_role.amcal_ec2_role.name
}

# Instance Profile for EC2 to Assume Role
resource "aws_iam_instance_profile" "amcal_ec2_profile" {
  name = "amcal_ec2_profile"
  role = aws_iam_role.amcal_ec2_role.name
}

# Security Group
resource "aws_security_group" "amcal_sg" {
  name        = "amcal_sg"
  description = "Allow inbound traffic"

  tags = {
    Name = "amcal_sg"
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "amcal_ec2" {
  instance_type   = var.instance_type
  security_groups = [aws_security_group.amcal_sg.name]
  count           = 4
  ami            = var.ami
  key_name       = var.key_name

  # Attach the IAM Role
  iam_instance_profile = aws_iam_instance_profile.amcal_ec2_profile.name

  tags = {
    Name = "amcal-${count.index + 1}"
  }
}
