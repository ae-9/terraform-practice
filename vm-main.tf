#####################################
#  begin ec2 instance specs  below  #
#####################################

/* additional info for RHEL
    AMI ID:             ami-0583d8c7a9c35822c
    AMI Name:           RHEL-9.4.0_HVM-20240605-x86_64-82-Hourly2-GP3
    AMI Location:       amazon/RHEL-9.4.0_HVM-20240605-x86_64-82-Hourly2-GP3
    Platform details:   Red Hat Enterprise Linux
    Owner:              301089707552
*/

# ami specs for RHEL 9
data "aws_ami" "rhel_9" {
  most_recent = true

  owners = ["301089707552"] // Red Hat, came from creating a new vm

  # filter {
  #   name   = "name"
  #   values = ["RHEL-9.4.0_HVM-20240605-x86_64-82-Hourly2-GP3"]
  # }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# create the ec2
resource "aws_instance" "ec2_instance" {
  ami                         = data.aws_ami.rhel_9.id
  instance_type               = var.ec2_instance_type
  subnet_id                   = aws_subnet.ec2_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.ec2_security_group.id]
  associate_public_ip_address = var.ec2_public_ip_association
  source_dest_check           = false
  key_name                    = aws_key_pair.ec2_key_pair.key_name
  user_data                   = file("./user_data.sh")

  # root disk
  root_block_device {
    volume_size           = var.ec2_root_volume_size
    volume_type           = var.ec2_root_volume_type
    delete_on_termination = false
    encrypted             = true
  }

  tags = {
    Name = "${var.ec2_use_case}-instance"
  }
}

# Elastic IP 
resource "aws_eip" "ec2_eip" {
  domain = "vpc"
  tags = {
    Name    = "${var.ec2_use_case}-eip" // ec2_RHEL_vm-eip
    usecase = "${var.ec2_use_case}"     // ec2_demo
  }
}

# Associate Elastic IP
resource "aws_eip_association" "ec2_eip_association" {
  instance_id   = aws_instance.ec2_instance.id
  allocation_id = aws_eip.ec2_eip.id
}


####################################
#  begin networking configs below  #
####################################

# VPC
resource "aws_vpc" "ec2_vpc" {
  cidr_block           = var.ec2_vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "${var.ec2_use_case}-vpc" // ec2_demo-vpc
  }
}

# Subnet - public
resource "aws_subnet" "ec2_public_subnet" {
  vpc_id     = aws_vpc.ec2_vpc.id
  cidr_block = var.ec2_public_subnet_cidr
  #region            = "us-east-1"
  #ec2_az            = "${var.ec2_az}"
  tags = {
    Name = "${var.ec2_use_case}-public-subnet" // ec2_demo-public-subnet

  }
}

# Internet gateway
resource "aws_internet_gateway" "ec2_igw" {
  vpc_id = aws_vpc.ec2_vpc.id
  tags = {
    Name = "${var.ec2_use_case}-igw" // ec2_demo-igw

  }
}

# Public route table
resource "aws_route_table" "ec2_public-rt" {
  vpc_id = aws_vpc.ec2_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ec2_igw.id
  }
  tags = {
    Name = "${var.ec2_use_case}-rt" //// ec2_demo-rt

  }
}

# Public route table to public subnet
resource "aws_route_table_association" "ec2_public-rt-association" {
  subnet_id      = aws_subnet.ec2_public_subnet.id
  route_table_id = aws_route_table.ec2_public-rt.id
}

# Security Group
resource "aws_security_group" "ec2_security_group" {
  name        = "${var.ec2_use_case}-sg" // ec2_demo-sg
  description = "allow traffic IN"
  vpc_id      = aws_vpc.ec2_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow all from internet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.ec2_use_case}-sg"
  }
}


# Generates a secure private key and encodes it as PEM
resource "tls_private_key" "ec2_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create the Key Pair
resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "${var.ec2_use_case}-keypair"
  public_key = tls_private_key.ec2_key_pair.public_key_openssh
}

# Save file
resource "local_file" "ssh_key" {
  filename = "${var.ec2_use_case}.ppk"
  content  = tls_private_key.ec2_key_pair.private_key_pem
}



# resource "aws_key_pair" "deployer" {
#   key_name   = "deployer-key"
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
# }