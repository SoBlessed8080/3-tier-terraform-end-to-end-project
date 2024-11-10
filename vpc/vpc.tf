#CREATING VPC-----------------------------------------------------------------
resource "aws_vpc" "apci_main_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-vpc"
  })
}

#CREATING INTERNET GATEWAY-------------------------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.apci_main_vpc.id

   tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-igw"
  })
}

#CREATING FRONTEND SUBNET 1A-------------------------------------------------------------
resource "aws_subnet" "frontend_subnet_az1a" {
  vpc_id     = aws_vpc.apci_main_vpc.id
  cidr_block = var.frontend_cidr_block[0]
  availability_zone = var.availability_zone[0]

    tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-frontend_subnet_az1a"
  })
}

#CREATING FRONTEND SUBNET 1B---------------------------------------------------------------------
resource "aws_subnet" "frontend_subnet_az1b" {
  vpc_id     = aws_vpc.apci_main_vpc.id
  cidr_block = var.frontend_cidr_block[1]
  availability_zone = var.availability_zone[1]

    tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-frontend_subnet_az1b"
  })
}

#CREATING BACKEND SUBNET 1A-------------------------------------------------------------------
resource "aws_subnet" "backend_subnet_az1a" {
  vpc_id     = aws_vpc.apci_main_vpc.id
  cidr_block = var.backend_cidr_block[0]
  availability_zone = var.availability_zone[0]

    tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-backend_subnet_az1a"
  })
}

#CREATING BACKEND SUBNET 1B-------------------------------------------------------------------
resource "aws_subnet" "backend_subnet_az1b" {
  vpc_id     = aws_vpc.apci_main_vpc.id
  cidr_block = var.backend_cidr_block[1]
  availability_zone = var.availability_zone[1]

    tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-backend_subnet_az1b"
  })
}

#CREATING DATABASE SUBNET 1A ------------------------------------------------------------------
resource "aws_subnet" "db_subnet_az1a" {
  vpc_id     = aws_vpc.apci_main_vpc.id
  cidr_block = var.backend_cidr_block[2]
  availability_zone = var.availability_zone[0]

    tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db_subnet_az1a"
  })
}

#CREATING DATABASE SUBNET 1B -----------------------------------------------------------------
resource "aws_subnet" "db_subnet_az1b" {
  vpc_id     = aws_vpc.apci_main_vpc.id
  cidr_block = var.backend_cidr_block[3]
  availability_zone = var.availability_zone[1]

    tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db_subnet_az1b"
  })
}

#CREATING PUBLIC ROUTE TABLE---------------------------------------------------------------------------------
resource "aws_route_table" "apci_public_rt" {
  vpc_id = aws_vpc.apci_main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }


    tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public_rt"
  })
}

#CREATING FRONTEND SUBNET AZ1A ASSOCIATION TO PUBLIC ROUTE TABLE-----------------------------------------
resource "aws_route_table_association" "frontend_subnet_az1a" {
  subnet_id      = aws_subnet.frontend_subnet_az1a.id
  route_table_id = aws_route_table.apci_public_rt.id
}

#CREATING FRONTEND SUBNET AZ1B ASSOCIATION TO PUBLIC ROUTE TABLE-----------------------------------------
resource "aws_route_table_association" "frontend_subnet_az1b" {
  subnet_id      = aws_subnet.frontend_subnet_az1b.id
  route_table_id = aws_route_table.apci_public_rt.id
}

#CREATING ELASTIC IP FOR NAT GATEWAY IN AZ1A------------------------------------------------------------------
resource "aws_eip" "eip_az1a" {
  
  domain   = "vpc"

   tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip_az1a"
  })
}

#CREATING A NAT GATEWAY FOR AZ1A----------------------------------------------------------------------------
resource "aws_nat_gateway" "nat_gw_az1a" {
  allocation_id = aws_eip.eip_az1a.id
  subnet_id     = aws_subnet.frontend_subnet_az1a.id

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat_gw"
  })

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.eip_az1a, aws_subnet.frontend_subnet_az1a]
}

#CREATING PRIVATE ROUTE TABLE FOR AZ1A------------------------------------------------------------------------
resource "aws_route_table" "apci_private_rt_az1a" {
  vpc_id = aws_vpc.apci_main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw_az1a.id
  }


    tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private_rt_az1a"
  })
}

#CREATING BACKEND SUBNET AZ1A ASSOCIATION TO PRIVATE ROUTE TABLE-----------------------------------------
resource "aws_route_table_association" "backend_subnet_az1a" {
  subnet_id      = aws_subnet.backend_subnet_az1a.id
  route_table_id = aws_route_table.apci_private_rt_az1a.id
}

#CREATING DB SUBNET AZ1A ASSOCIATION TO PRIVATE ROUTE TABLE
resource "aws_route_table_association" "db_subnet_az1a" {
  subnet_id      = aws_subnet.db_subnet_az1a.id
  route_table_id =aws_route_table.apci_private_rt_az1a.id
}

#CREATING AN EIP FOR AZ1B--------------------------------------------------------------------------
resource "aws_eip" "eip_az1b" {
  
  domain   = "vpc"

   tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip_az1b"
  })
}

#CREATING A NAT GATEWAY FOR AZ1B----------------------------------------------------------------------------
resource "aws_nat_gateway" "nat_gw_az1b" {
  allocation_id = aws_eip.eip_az1b.id
  subnet_id     = aws_subnet.frontend_subnet_az1b.id

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat_gw_az1b"
  })

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.eip_az1a, aws_subnet.frontend_subnet_az1b]
}

#CREATING PRIVATE ROUTE TABLE FOR AZ1B------------------------------------------------------------------------
resource "aws_route_table" "apci_private_rt_az1b" {
  vpc_id = aws_vpc.apci_main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw_az1b.id
  }


    tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private_rt_az1b"
  })
}
#CREATING BACKEND SUBNET AZ1A ASSOCIATION TO PRIVATE ROUTE TABLE-----------------------------------------
resource "aws_route_table_association" "backend_subnet_az1b" {
  subnet_id      = aws_subnet.backend_subnet_az1b.id
  route_table_id = aws_route_table.apci_private_rt_az1b.id
}

#CREATING DB SUBNET AZ1A ASSOCIATION TO PRIVATE ROUTE TABLE-------------------------------------------
resource "aws_route_table_association" "db_subnet_az1b" {
  subnet_id      = aws_subnet.db_subnet_az1b.id
  route_table_id =aws_route_table.apci_private_rt_az1b.id
}


