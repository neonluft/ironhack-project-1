output "private_ip_db" {
  description = "private ip of the backend db instance"
  value = aws_instance.ec2_backend_db.private_ip
}