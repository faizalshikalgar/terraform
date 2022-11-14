provider "aws" {
    region = "ap-south-1"
}

variable env_prefix {}
variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}



resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "my-vpc-sunbet-1" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone

  tags = {
    Name = "${var.env_prefix}-subnet"
  }
}