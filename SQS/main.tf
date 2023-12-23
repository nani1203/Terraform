# provider details
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}


resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  #enable_dns_support = true
  #enable_dns_hostnames = true

  tags = {
    Name = "vpc01"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.vpc.id # Replace with your VPC ID
  cidr_block        = "10.0.0.0/24"  # Replace with your desired CIDR block
  availability_zone = "ap-south-1a"  # Replace with your desired Availability Zone

  # Optional: Assign tags to your subnets
  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.vpc.id # Replace with your VPC ID
  cidr_block        = "10.0.1.0/24"  # Replace with your desired CIDR block
  availability_zone = "ap-south-1b"  # Replace with your desired Availability Zone

  # Optional: Assign tags to your subnets
  tags = {
    Name = "Private Subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  # Optional: Assign tags to your Internet Gateway
  tags = {
    Name = "My Internet Gateway"
  }
}

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  # Optional: Assign tags to your route table
  tags = {
    Name = "MyRouteTable"
  }
}

resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.vpc.id
  # You can add custom routes here if needed

  # For example, to route traffic within the VPC:
  # route {
  #   cidr_block = "10.0.0.0/16"
  #   vpc_peering_connection_id = aws_vpc_peering_connection.example.id
  # }
}

resource "aws_route_table_association" "subnet1_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table_association" "subnet2_association" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.rt2.id
}

# Create a security group
resource "aws_security_group" "example_security_group" {
  name_prefix = "example-security-group"
  description = "Example security group"
  vpc_id      = aws_vpc.vpc.id

  # Define your security group rules as needed
  # For example, allow SSH and HTTP traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# To create the Ec2 instance
resource "aws_instance" "example_instance" {
  ami                         = var.ami           # Change to your desired AMI ID
  instance_type               = var.instance_type # Change to your desired instance type
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true         # Enable a public IP
  key_name                    = var.key_name # Change to your key pair name
  availability_zone           = var.availability_zone
  user_data                   = filebase64("/home/ec2-user/sqs/file.sh")
  vpc_security_group_ids      = [aws_security_group.example_security_group.id]
  #user_data = <<-EOF
  #!/bin/bash
  #sudo echo "Hello from user data!" > /tmp/file123.txt
  # You can put any shell script or commands here
  #EOF

  root_block_device {
    volume_size = 10
    volume_type = "gp2"
  }

  tags = {
    Name = "Ec-1"
  }
}

# To create the Ec2 instance
resource "aws_instance" "example_instance1" {
  ami                         = var.ami           # Change to your desired AMI ID
  instance_type               = var.instance_type # Change to your desired instance type
  subnet_id                   = aws_subnet.private.id
  associate_public_ip_address = true         # Enable a public IP
  key_name                    = var.key_name # Change to your key pair name
  availability_zone           = "ap-south-1b"
  #user_data                   = filebase64("/home/ec2-user/file.sh")
  vpc_security_group_ids = [aws_security_group.example_security_group.id]
  #user_data = <<-EOF
  #!/bin/bash
  #sudo echo "Hello from user data!" > /tmp/file123.txt
  # You can put any shell script or commands here
  #EOF

  root_block_device {
    volume_size = 10
    volume_type = "gp2"
  }

  tags = {
    Name = "Ec-2"
  }
}
