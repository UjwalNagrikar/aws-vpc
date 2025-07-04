# VPC
resource "aws_vpc" "Ujwal-VPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "Ujwal-VPC"
  }
}

# Internet Gateway (single definition)
resource "aws_internet_gateway" "Ujwal-IGW" {
  vpc_id = aws_vpc.Ujwal-VPC.id
  tags = {
    Name = "Ujwal-IGW"
  }
}

# Public Subnet
resource "aws_subnet" "public-subnet-1" {
  vpc_id     = aws_vpc.Ujwal-VPC.id
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "public-subnet-1"
  }
}

# Private Subnet
resource "aws_subnet" "privet-subnet-2" {
  vpc_id     = aws_vpc.Ujwal-VPC.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "privet-subnet"
  }
}

# Route Table
resource "aws_route_table" "my-route" {
  vpc_id = aws_vpc.Ujwal-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Ujwal-IGW.id
  }

  tags = {
    Name = "my-route"
  }
}

# Route Table Association
resource "aws_route_table_association" "route-association" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.my-route.id
}


# EC2 Instance
resource "aws_instance" "Ujwal-Server" {
  ami                         = "ami-0f918f7e67a3323f0"
  instance_type               = "t2.micro"
  key_name                    = "Ujwal-SRE"
  subnet_id                   = aws_subnet.public-subnet-1.id
  associate_public_ip_address = true
  tags = {
    Name = "Ujwal-Server"
  }
}
