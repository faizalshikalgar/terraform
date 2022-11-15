provider "aws" {
    region = "ap-south-1"
}

variable env_prefix {}
variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable my_ip {}
variable instance_type {}
variable public_key_location {}



resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr_block
  tags       = {
    Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "my-vpc-sunbet-1" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags              = {
    Name = "${var.env_prefix}-subnet"
  }
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags   = {
    Name = "${var.env_prefix}-igw"
  }
}

resource "aws_route_table" "my-rtb" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }

  tags = {
    Name = "${var.env_prefix}-rtb"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.my-vpc-sunbet-1.id
  route_table_id = aws_route_table.my-rtb.id
}

resource "aws_security_group" "my-sg" {
  name        = "my-sg"
  description = "created by terraform 22 & 8080"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip]
  }

  ingress {
    from_port        = 8080
    to_port          = 8080
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
    public_key = file(var.public_key_location)
}

resource "aws_instance" "myapp-server" {
  ami           = data.aws_ami.my_ami.id
  instance_type = var.instance_type
  
  availability_zone            = var.avail_zone
  subnet_id                    = aws_subnet.my-vpc-sunbet-1.id
  vpc_security_group_ids       = [aws_security_group.my-sg.id]
  associate_public_ip_address  = true
  key_name                     = aws_key_pair.ssh_key.key_name

  tags = {
    Name = "${var.env_prefix}-server"
  }
}

output "image_id" {
  value = data.aws_ami.my_ami.id
}

output "public_ip" {
  value = aws_instance.myapp-server.public_ip
}