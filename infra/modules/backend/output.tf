output "public_ip_backend" {
  description = "the public ip adress of the backend ec2 instance"
  value = aws_instance.ec2_backend.private_ip
}