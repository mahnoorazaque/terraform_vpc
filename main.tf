resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "main-igw"
    }
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidr
    availability_zone = var.availability_zone
    map_public_ip_on_launch = true
    tags = {
        Name = "public-subnet"
    }
}
 
resource "aws_subnet" "private" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_cidr
    availability_zone = var.availability_zone
    tags = {
        Name = "private-subnet"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "public-rt"
    }
}

resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
    vpc = true
}

resource "aws_nat_gateway" "natgw" {
    allocation_id = aws_eip.nat.id
    subnet_id = aws_subnet.public.id
    depends_on = [ aws_internet_gateway.igw]
    tags = {
        Name = "nat-gateway"
    }
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.natgw.id
    }
    tags = {
        Name = "private-rt"
    }
}

resource "aws_route_table_association" "private" {
    subnet_id = aws_subnet.private.id
    route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "public_sg" {
    name = "public-sg"
    description = "Allow SSH and HTTP"
    vpc_id = aws_vpc.main.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
resource "aws_security_group" "private_sg" {
    name        = "private-sg"
    description = "Allow outbound traffic only"
    vpc_id      = aws_vpc.main.id

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "public_instance" {
    ami                         = var.instance_ami
    instance_type               = var.instance_type
    subnet_id                   = aws_subnet.public.id
    vpc_security_group_ids      = [aws_security_group.public_sg.id]
    associate_public_ip_address = true

    tags = { Name = "public-ec2" }
}


resource "aws_instance" "private_instance" {
    ami                    = var.instance_ami
    instance_type          = var.instance_type
    subnet_id              = aws_subnet.private.id
    vpc_security_group_ids = [aws_security_group.private_sg.id]

    tags = { Name = "private-ec2" }
}
