provider "aws" {
  region = "us-east-1"
}

# -------------------------
# Get latest Bitnami Tomcat AMI
# -------------------------
data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

# -------------------------
# Get default VPC
# -------------------------
data "aws_vpc" "default" {
  default = true
}

# -------------------------
# Get a default subnet (any AZ)
# -------------------------
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# -------------------------
# Security group in default VPC
# -------------------------
resource "aws_security_group" "web" {
  name   = "web-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 8080
    to_port     = 8080
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
    Name = "web-sg"
  }
}

# -------------------------
# EC2 Instance
# -------------------------
resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = "t3.nano"

  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.web.id]

  tags = {
    Name = "HelloWorld"
  }
}
