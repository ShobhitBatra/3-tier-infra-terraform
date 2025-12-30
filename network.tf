# Creating vpc
resource "aws_vpc" "vpc_main" {
    cidr_block = var.vpc_cidr_block
    tags = {
      Name = "vpc-main"
    }
}

# Creating 8 subnets in this vpc (2 public and 6 private)

# Creating 2 public subnets
resource "aws_subnet" "subnet_public_infra_a" {
  vpc_id = aws_vpc.vpc_main.id
  cidr_block = "192.168.0.0/27"
  availability_zone = var.availability_zones[0]
  map_public_ip_on_launch = true
  tags = {
    Name= "subnet-public-infra-a"
  }
}

resource "aws_subnet" "subnet_public_infra_b" {
  vpc_id = aws_vpc.vpc_main.id
  cidr_block = "192.168.0.32/27"
  availability_zone = var.availability_zones[1]
  map_public_ip_on_launch = true
  tags = {
    Name= "subnet-public-infra-b"
  }
}


# Creating 6 private subnet

# Creating web tier subnets
resource "aws_subnet" "subnet_private_web_a" {
  vpc_id = aws_vpc.vpc_main.id
  cidr_block = "192.168.0.64/27"
  availability_zone = var.availability_zones[0]
  tags = {
    Name= "subnet-private-web-a"
  }
}

resource "aws_subnet" "subnet_private_web_b" {
  vpc_id = aws_vpc.vpc_main.id
  cidr_block = "192.168.0.96/27"
  availability_zone = var.availability_zones[1]
  tags = {
    Name= "subnet-private-web-b"
  }
}

# Creating app tier subnets
resource "aws_subnet" "subnet_private_app_a" {
  vpc_id = aws_vpc.vpc_main.id
  cidr_block = "192.168.0.128/27"
  availability_zone = var.availability_zones[0]
  tags = {
    Name= "subnet-private-app-a"
  }
}

resource "aws_subnet" "subnet_private_app_b" {
  vpc_id = aws_vpc.vpc_main.id
  cidr_block = "192.168.0.160/27"
  availability_zone = var.availability_zones[1]
  tags = {
    Name= "subnet-private-app-b"
  }
}

# Creating db tier subnets
resource "aws_subnet" "subnet_private_db_a" {
  vpc_id = aws_vpc.vpc_main.id
  cidr_block = "192.168.0.192/27"
  availability_zone = var.availability_zones[0]
  tags = {
    Name= "subnet-private-db-a"
  }
}

resource "aws_subnet" "subnet_private_db_b" {
  vpc_id = aws_vpc.vpc_main.id
  cidr_block = "192.168.0.224/27"
  availability_zone = var.availability_zones[1]
  tags = {
    Name= "subnet-private-db-b"
  }
}


# Creating internet gateway
resource "aws_internet_gateway" "igw_main" {
  vpc_id = aws_vpc.vpc_main.id
  tags = {
    Name = "igw-main"
  }
}

# Creating nat gateways

# Creating eip in az-a for nat-gw-a
resource "aws_eip" "eip_nat_a" {
  domain = "vpc"
  tags = {
    Name="eip-nat-a"
  }
}

# Creating eip in az-b for nat-gw-b
resource "aws_eip" "eip_nat_b" {
  domain = "vpc"
  tags = {
    Name="eip-nat-b"
  }
}

# Creating nat in az-a
resource "aws_nat_gateway" "nat_gw_public_infra_a" {
  subnet_id = aws_subnet.subnet_public_infra_a.id
  allocation_id = aws_eip.eip_nat_a.id
  tags = {
    Name = "nat-gw-public-infra-a"
  }
}

# Creating nat in az-b
resource "aws_nat_gateway" "nat_gw_public_infra_b" {
  subnet_id = aws_subnet.subnet_public_infra_b.id
  allocation_id = aws_eip.eip_nat_b.id
  tags = {
    Name = "nat-gw-public-infra-b"
  }
}


# Creating Route tables

# Creating public route table
resource "aws_route_table" "rt_public" {
    vpc_id = aws_vpc.vpc_main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_main.id
    }
    tags= {
        Name= "rt-public"
    }  
}

# Creating private route tables

# az-a
resource "aws_route_table" "rt_private_a" {
    vpc_id = aws_vpc.vpc_main.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gw_public_infra_a.id
    }

    tags= {
        Name= "rt-private-a"
    }  
}

# az-b
resource "aws_route_table" "rt_private_b" {
    vpc_id = aws_vpc.vpc_main.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gw_public_infra_b.id
    }
    tags= {
        Name= "rt-private-b"
    }  
}


# Creating route table associations for public subnets
resource "aws_route_table_association" "rta_public_infra_a" {
  subnet_id = aws_subnet.subnet_public_infra_a.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "rta_public_infra_b" {
  subnet_id = aws_subnet.subnet_public_infra_b.id
  route_table_id = aws_route_table.rt_public.id
}

# Creating route table associations for private subnets 

# for az-a
resource "aws_route_table_association" "rta_private_web_a" {
  subnet_id = aws_subnet.subnet_private_web_a.id
  route_table_id = aws_route_table.rt_private_a.id
}

resource "aws_route_table_association" "rta_private_app_a" {
  subnet_id = aws_subnet.subnet_private_app_a.id
  route_table_id = aws_route_table.rt_private_a.id
}

resource "aws_route_table_association" "rta_private_db_a" {
  subnet_id = aws_subnet.subnet_private_db_a.id
  route_table_id = aws_route_table.rt_private_a.id
}

# for az-b
resource "aws_route_table_association" "rta_private_web_b" {
  subnet_id = aws_subnet.subnet_private_web_b.id
  route_table_id = aws_route_table.rt_private_b.id
}

resource "aws_route_table_association" "rta_private_app_b" {
  subnet_id = aws_subnet.subnet_private_app_b.id
  route_table_id = aws_route_table.rt_private_b.id
}

resource "aws_route_table_association" "rta_private_db_b" {
  subnet_id = aws_subnet.subnet_private_db_b.id
  route_table_id = aws_route_table.rt_private_b.id
}

