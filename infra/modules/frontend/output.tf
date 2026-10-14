output "frontend" {
  description = "all the needed information for frontend - for the ansible file"
  value = {
    public_ip = aws_instance.ec2_frontend.public_ip
    hostname = aws_instance.ec2_frontend.tags.Name
  }
}