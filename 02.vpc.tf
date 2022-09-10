### CREATE VPC ###
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc-${var.cluster_name}"
    Eks  = "${var.cluster_name}"
  }
}



### CREATE INTERNET GATEWAY ###
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
    Eks  = "${var.cluster_name}"
  }
}



### CREATE PRIVATE SUBNETS FOR NODES ###
resource "aws_subnet" "private-a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/19"
  availability_zone = "${var.aws_region}a"

  tags = {
    "Name"                            = "private-${var.aws_region}a"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "Eks" = "${var.cluster_name}"
  }
}

resource "aws_subnet" "private-b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.32.0/19"
  availability_zone = "${var.aws_region}b"

  tags = {
    "Name"                            = "private-${var.aws_region}b"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "Eks" = "${var.cluster_name}"
  }
}


### CREATE PUBLIC SUBNETS FOR EXTERNAL LOADBALANCERS ###
resource "aws_subnet" "public-a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.64.0/19"
  availability_zone       = "${var.aws_region}a"

  tags = {
    "Name"                            = "public-${var.aws_region}a"
    "kubernetes.io/role/elb"          = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "Eks" = "${var.cluster_name}"
  }
}

resource "aws_subnet" "public-b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.96.0/19"
  availability_zone       = "${var.aws_region}b"

  tags = {
    "Name"                            = "public-${var.aws_region}b"
    "kubernetes.io/role/elb"          = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "Eks" = "${var.cluster_name}"
  }
}



### CREATE A PUBLIC IP FOR NAT GATEWAY ###
resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "nat"
    Eks  = "${var.cluster_name}"
  }
}


### CREATE NAT GATEWAY FOR WORKDER NODES ###
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-a.id

  tags = {
    Name = "nat"
    Eks  = "${var.cluster_name}"
  }

  depends_on = [aws_internet_gateway.igw]
}



### DEFINE ROUTE TABLE FOR PRIVATE SUBNET ###
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      nat_gateway_id             = aws_nat_gateway.nat.id
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      gateway_id                 = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    },
  ]

  tags = {
    Name = "private"
    Eks  = "${var.cluster_name}"
  }
}

### DEFINE ROUTE TABLE FOR PUBLIC SUBNET ###
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.igw.id
      nat_gateway_id             = ""
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    },
  ]

  tags = {
    Name = "public"
    Eks  = "${var.cluster_name}"
  }
}


### ATTACH ROUTE TABLES TO SUBNETS ###
resource "aws_route_table_association" "private-a" {
  subnet_id      = aws_subnet.private-a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-b" {
  subnet_id      = aws_subnet.private-b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public-a" {
  subnet_id      = aws_subnet.public-a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-b" {
  subnet_id      = aws_subnet.public-b.id
  route_table_id = aws_route_table.public.id
}