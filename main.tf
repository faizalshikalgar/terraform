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

module "my-app-server" {
  source = "./modules/webserver"

  vpc_id        = aws_vpc.my-vpc.id
  env_prefix    = var.env_prefix
  image_name    = var.image_name
  public_key    = var.public_key
  instance_type = var.instance_type
  avail_zone    = var.avail_zone
  subnet_id     = module.my-subnet.subnet.id
  
}