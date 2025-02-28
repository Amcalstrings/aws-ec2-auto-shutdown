terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.81.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

# create security group

resource "aws_security_group" "amcal_sg" {
  name        = "amcal_sg"
  description = "Allow TLS inbound traffic"
  
  tags = {
    Name = "amcal_sg"
  }

  ingress {
    description = "TLS FROM VPC"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

   ingress {
    description = "TLS FROM VPC"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  } 

  
  
    
  egress {
    description = "TLS FROM VPC"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
  }
}

# create ec2 instance
resource "aws_instance" "amcal_ec2" {
  instance_type = var.instance_type
  security_groups = [ aws_security_group.amcal_sg.name ]
  count = 4
  ami           = var.ami
  key_name      = var.key_name
  tags = {
    Name = "amcal-${count.index + 1}"
  }

}

