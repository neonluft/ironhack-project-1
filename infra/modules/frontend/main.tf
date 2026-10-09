# Create VM
resource "aws_instance" "ec2_frontend" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  associate_public_ip_address = true
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = var.frontend_security_group_id
  key_name                    = var.key_name

  tags = {
    Name        = "${var.student_name}-frontend"
    Environment = "Dev"
    ManagedBy   = "Florik"
    Owner       = "Florik"
  }
}
