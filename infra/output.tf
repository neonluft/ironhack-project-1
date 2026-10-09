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
