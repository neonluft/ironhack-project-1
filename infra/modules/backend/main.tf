# Create VM
resource "aws_instance" "ec2_backend" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  associate_public_ip_address = false
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = var.backend_security_group_id
  key_name                    = var.key_name

  tags = {
    Name        = "${var.student_name}-backend"
    Environment = "Dev"
    ManagedBy   = "Florik"
    Owner       = "Florik"
  }
}
