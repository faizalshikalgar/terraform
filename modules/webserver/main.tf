resource "aws_security_group" "my-sg" {
  name        = "my-sg"
  description = "created by terraform 22 & 8080"
  vpc_id      = var.vpc_id

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
    values = [var.image_name]
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
  subnet_id                    = var.subnet_id
  vpc_security_group_ids       = [aws_security_group.my-sg.id]
  associate_public_ip_address  = true
  key_name                     = aws_key_pair.ssh_key.key_name

  user_data = file("entry-script.sh")
  
  tags = {
    Name = "${var.env_prefix}-server"
  }
  

}