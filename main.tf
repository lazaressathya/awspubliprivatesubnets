## creating a locals for file
locals {
  development_env = "development"
}
###creating a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${local.development_env}-vpc-tag"
  }
}
### creating a public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet1    
  availability_zone = var.az1
  tags = {
    Name = "${local.development_env}-pubSubnet-tag"
  }
}
##creating a private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet2
  availability_zone = var.az2
  tags = {
    Name = "${local.development_env}-priSubnet-tag"
  }
}
##creating internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "${local.development_env}-IGW-tag"
  }
}
## route table for public subnet
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = var.publicroute
    gateway_id = aws_internet_gateway.demogateway.id
  }
  tags = {
    Name = "${local.development_env}-publicroute-tag"
  }
}

resource "aws_route_table_association" "route_table_asso_public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route.id
}

# Creating Route table for Private Subnet
resource "aws_route_table" "private_route" {
    vpc_id = aws_vpc.my_vpc.id
tags = {
        Name = "${local.development_env}-privateroute-tag"
    }
}
resource "aws_route_table_association" "route_table_asso_private" {
    subnet_id = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.private_route.id
}

# Creating EC2 instance in Private Subnet
resource "aws_instance" "privateinstance" {
  ami                    = "ami-087c17d1fe0178315"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  subnet_id              = "${aws_subnet.private_subnet.id}"
  tags = {
    Name = "${local.development_env}-privateEC2-tag"
  }
}
resource "aws_instance" "publicinstance" {
  ami                    = "ami-087c17d1fe0178315"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  subnet_id              = "${aws_subnet.public_subnet.id}"
  tags = {
    Name = "${local.development_env}-publicEC2-tag"
  }
}

## creating a security group
resource "aws_security_group" "publicsg" {
vpc_id      = "${aws_vpc.my_vpc.id}"
# Inbound Rules
  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# Outbound Rules
  # Internet access to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creating NAT Gateway
resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet.id
}
# Creating EIP
resource "aws_eip" "eip" {
  vpc = true
}



