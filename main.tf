provider "aws" {
  region     = "ap-northeast-1"
  access_key = ""
  secret_key = ""
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "private-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

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

resource "aws_route_table_association" "public-association-1" {
  subnet_id      = aws_subnet.public-1.id
  route_table_id = aws_route_table.public.id
}
resource "aws_eip" "nat-1" {
  vpc = true
}

resource "aws_nat_gateway" "nat-1" {
  allocation_id = aws_eip.nat-1.id
  subnet_id     = aws_subnet.public-1.id

  tags = {
    Name = "gw NAT"
  }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-rt"
  }
}
resource "aws_route_table_association" "private-association-1" {
  subnet_id      = aws_subnet.private-1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route" "private-route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat-1.id
}
