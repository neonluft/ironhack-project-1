output "public_ip_frontend" {
  description = "the public IP adress of the frontend ec2 instance"
  value = aws_instance.ec2_frontend.private_ip
}