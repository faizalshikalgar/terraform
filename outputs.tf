output "image_id" {
  value = data.aws_ami.my_ami.id
}

output "public_ip" {
  value = aws_instance.myapp-server-one.public_ip
}