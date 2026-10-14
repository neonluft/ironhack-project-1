variable "student_name" {
  type        = string
  description = "Your unique cloud-specialist itentifier, appended to resource names."
  default     = "florik"
}

# key for ssh purposes
variable "key_name" {
  description = "key used for connection"
  type        = string
  default     = "floriksep26"
}

variable "base_cidr_block" {
  description = "The base CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_base_cidr_block" {
  description = "the base CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_base_cidr_block" {
  description = "the base CIDR block for the public subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_base_cidr_block_db" {
  description = "the base CIDR block for the public subnet"
  type        = string
  default     = "10.0.3.0/24"
}

data "http" "my_ip" {
  url = "http://checkip.amazonaws.com"
}

locals {
  # The response ends with a newline, so trim it
  my_ip_cidr = "${chomp(data.http.my_ip.response_body)}/32"
}