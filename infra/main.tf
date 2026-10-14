
##### -----------------------------------------
# Network configurations - output is declared in the root module for reference for the child modules #
##### -----------------------------------------


#### VPC ###

resource "aws_vpc" "florik_vpc" {
  cidr_block           = var.base_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.student_name}-vpc"
  }
}


#### Public & Private Subnet ####


resource "aws_subnet" "florik_public_subnet" {
  vpc_id                  = aws_vpc.florik_vpc.id
  cidr_block              = var.public_subnet_base_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "${var.student_name}-PublicSubnet"
  }
}

resource "aws_subnet" "florik_private_subnet" {
  vpc_id                  = aws_vpc.florik_vpc.id
  cidr_block              = var.private_subnet_base_cidr_block
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1a"

  tags = {
    Name = "${var.student_name}-PrivateSubnet"
  }
}

resource "aws_subnet" "florik_private_subnet_db" {
  vpc_id                  = aws_vpc.florik_vpc.id
  cidr_block              = var.private_subnet_base_cidr_block_db
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1a"

  tags = {
    Name = "${var.student_name}-PrivateSubnet_DB"
  }
}

#### IGW , NAT & Routing ####

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.florik_vpc.id

  tags = {
    Name = "${var.student_name}-InternetGateway"
  }
}

resource "aws_route_table" "florik_public_rt" {
  vpc_id = aws_vpc.florik_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.student_name}-PublicRouteTable"
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.florik_public_subnet.id
  route_table_id = aws_route_table.florik_public_rt.id
}

resource "aws_eip" "nat_ip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]

  tags = { name = "${var.student_name}-nat-gateway-eip" }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_ip.id
  subnet_id     = aws_subnet.florik_public_subnet.id

  tags = { name = "${var.student_name}-nat-gw" }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.florik_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = { Name = "${var.student_name}-Private-RT" }

}

resource "aws_route_table_association" "private_rt_assoc" {
  subnet_id      = aws_subnet.florik_private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_db_assoc" {
  subnet_id      = aws_subnet.florik_private_subnet_db.id
  route_table_id = aws_route_table.private_rt.id
}

########## Security Groups ##############

## frontend sec group ##

resource "aws_security_group" "frontend_sg" {
  name        = "${var.student_name}-Frontend-EC2SecurityGroup"
  description = "Allow SSH access"
  vpc_id      = aws_vpc.florik_vpc.id

  ingress {
    description = "SSH from my IP Adress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip_cidr]
  }

  ingress {
    description = "Ping from my IP Adress"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [local.my_ip_cidr]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP 8080 from anywhere"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP 8080 from anywhere"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.student_name}-Frontend-EC2SecurityGroup"
  }
}

### backend sec group ##

resource "aws_security_group" "backend_sg" {
  name        = "${var.student_name}-backend-sg"
  description = "Allow backend access strictly from the frontend security group"
  vpc_id      = aws_vpc.florik_vpc.id

  tags = {
    Name = "${var.student_name}-backend-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "backend_from_frontend" {
  security_group_id            = aws_security_group.backend_sg.id
  referenced_security_group_id = aws_security_group.frontend_sg.id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "backend_from_frontend_ssh" {
  security_group_id            = aws_security_group.backend_sg.id
  referenced_security_group_id = aws_security_group.frontend_sg.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "backend_to_backend_db" {
  security_group_id            = aws_security_group.backend_sg.id
  referenced_security_group_id = aws_security_group.backend_db_sg.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "backend_http_traffic_out" {
  security_group_id = aws_security_group.backend_sg.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "backend_https_traffic_out" {
  security_group_id = aws_security_group.backend_sg.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

### backend db sec group ###

resource "aws_security_group" "backend_db_sg" {
  name        = "${var.student_name}-backend-db-sg"
  description = "Allow backend access strictly from the frontend security group"
  vpc_id      = aws_vpc.florik_vpc.id

  tags = {
    Name = "${var.student_name}-backend-db-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "backend_db_from_frontend" {
  security_group_id            = aws_security_group.backend_db_sg.id
  referenced_security_group_id = aws_security_group.frontend_sg.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "backend_db_from_frontend_ssh" {
  security_group_id            = aws_security_group.backend_db_sg.id
  referenced_security_group_id = aws_security_group.frontend_sg.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "backend_db_from_backend" {
  security_group_id            = aws_security_group.backend_db_sg.id
  referenced_security_group_id = aws_security_group.backend_sg.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "backend_db_http_traffic_out" {
  security_group_id = aws_security_group.backend_db_sg.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "backend_db_https_traffic_out" {
  security_group_id = aws_security_group.backend_db_sg.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}




###### calling module frontnend & passing variables ####

module "frontend" {
  source = "./modules/frontend"

  vpc_id                     = aws_vpc.florik_vpc.id
  public_subnet_id           = aws_subnet.florik_public_subnet.id
  frontend_security_group_id = [aws_security_group.frontend_sg.id]
  key_name                   = var.key_name
  student_name               = var.student_name
}

module "backend" {
  source = "./modules/backend"

  vpc_id                    = aws_vpc.florik_vpc.id
  private_subnet_id         = aws_subnet.florik_private_subnet.id
  backend_security_group_id = [aws_security_group.backend_sg.id]
  key_name                  = var.key_name
  student_name              = var.student_name
}

module "db" {
  source = "./modules/db"

  vpc_id                    = aws_vpc.florik_vpc.id
  private_subnet_id         = aws_subnet.florik_private_subnet_db.id
  backend_security_group_id = [aws_security_group.backend_db_sg.id]
  key_name                  = var.key_name
  student_name              = var.student_name
}

##### creating the ansible inventory file ####/

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.ini"


  content = <<EOF
[frontend]
${module.frontend.frontend.hostname} ansible_host=${module.frontend.frontend.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/floriksep26.pem

[backend]
${module.backend.hostname} private_ip=${module.backend.private_ip_backend}

[db]
${module.db.hostname} private_ip=${module.db.private_ip_db}

EOF
}

resource "local_file" "ssh_config" {
  content = templatefile("${path.module}/ssh_config_template", {
    frontend_public_ip = module.frontend.frontend.public_ip
    backend_private_ip = module.backend.private_ip_backend
    db_private_ip      = module.db.private_ip_db
  })

  filename        = pathexpand("~/.ssh/florik_config")
  file_permission = "0600"
}