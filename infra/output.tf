output "myVPC" {
  description = "output of florik-vpc id for the child modules"
  value       = aws_vpc.florik_vpc.id
}

output "public_subnet" {
  description = "the id of my public subnet declared in the root module for reference for the child modules"
  value       = aws_subnet.florik_public_subnet.id
}

output "private_subnet" {
  description = "the id of my private subnet declared in the root module for reference for the child modules"
  value       = aws_subnet.florik_private_subnet.id
}

output "db" {
  value = {
    private_ip = module.db.private_ip_db
    hostname   = module.db.hostname
  }
}

output "backend" {
  value = {
    private_ip = module.backend.private_ip_backend
    hostname   = module.backend.hostname
  }
}

output "frontend" {
  value = {
    public_ip = module.frontend.frontend.public_ip
    hostname  = module.frontend.frontend.hostname
  }
}