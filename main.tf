provider "aws" {
    region = "ap-south-1"
}

resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags       = {
    Name = "${var.env_prefix}-vpc"
  }
}

module "my-subnet" {
  source = "./modules/subnet"

  subnet_cidr_block = var.subnet_cidr_block
  avail_zone        = var.avail_zone
  env_prefix        = var.env_prefix
  vpc_id            = aws_vpc.my-vpc.id
}

resource "aws_security_group" "my-sg" {
  name        = "my-sg"
  description = "created by terraform 22 & 8080"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.env_prefix}-sg"
  }
}

data "aws_ami" "my_ami" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "ssh_key" {
    key_name   = "myvm_ubuntu"
    public_key = file(var.public_key)
}

resource "aws_instance" "myapp-server-one" {
  ami           = data.aws_ami.my_ami.id
  instance_type = var.instance_type
  
  availability_zone            = var.avail_zone
  subnet_id                    = module.my-subnet.subnet.id
  vpc_security_group_ids       = [aws_security_group.my-sg.id]
  associate_public_ip_address  = true
  key_name                     = aws_key_pair.ssh_key.key_name

  tags = {
    Name = "${var.env_prefix}-server"
  }

}