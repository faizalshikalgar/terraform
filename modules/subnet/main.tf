resource "aws_subnet" "my-vpc-sunbet-1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags              = {
    Name = "${var.env_prefix}-subnet"
  }
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = var.vpc_id

  tags   = {
    Name = "${var.env_prefix}-igw"
  }
}

resource "aws_route_table" "my-rtb" {
  vpc_id = var.vpc_id

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