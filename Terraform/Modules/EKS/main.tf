# This Terraform configuration sets up a VPC with public and private subnets, an Internet Gateway, NAT Gateways, and appropriate route tables for an EKS cluster. The configuration is designed to be flexible, allowing for multiple availability zones and subnet CIDR blocks.

# aws_vpc - Creates a VPC with the specified CIDR block and enables DNS support and hostnames.
# var.vpc_cidr - The CIDR block for the VPC, defined as a variable for flexibility.
# tags - Tags are added to the VPC for identification and to associate it with the EKS cluster.
# var.cluster_name - The name of the EKS cluster, used in tags for resource identification.

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name                                           = "${var.cluster_name}-vpc"
    "kubernetes.io/cluster/${var.cluster_name}"    = "shared"
  }
}

# aws_subnet - Creates public and private subnets in the VPC. The number of subnets is determined by the length of the CIDR blocks provided in the variables.
# vpc_id - Associates the subnets with the VPC created earlier.
# var.private_subnet_cidrs and var.public_subnet_cidrs - Lists of CIDR blocks for private and public subnets, respectively.
# count - Used to create multiple subnets based on the number of CIDR blocks provided.
# shared tags - Tags are added to the subnets for identification and to associate them with the EKS cluster.
# The "kubernetes.io/role/internal-elb" and "kubernetes.io/role/elb" tags indicate the intended use of the subnets for internal and external load balancers, respectively.

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name                                           = "${var.cluster_name}-private-${count.index + 1}"
    "kubernetes.io/cluster/${var.cluster_name}"    = "shared"
    "kubernetes.io/role/internal-elb"              = "1"
  }
}

# map_public_ip_on_launch - This setting is enabled for public subnets to automatically assign public IP addresses to instances launched in these subnets.

resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name                                           = "${var.cluster_name}-public-${count.index + 1}"
    "kubernetes.io/cluster/${var.cluster_name}"    = "shared"
    "kubernetes.io/role/elb"                       = "1"
  }
}

# aws_internet_gateway - Creates an Internet Gateway and attaches it to the VPC, allowing resources in the public subnets to access the internet.
# aws_vpc.main.id - Associates the Internet Gateway with the VPC created earlier. 

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.cluster_name}-igw"
  }
}

# aws_eip and aws_nat_gateway - Creates Elastic IPs and NAT Gateways for each public subnet. The NAT Gateways allow instances in the private subnets to access the internet while keeping them secure.
# domain - Specifies that the Elastic IPs are for use in a VPC.

resource "aws_eip" "nat" {
  count = length(var.public_subnet_cidrs)
  domain = "vpc"

  tags = {
    Name = "${var.cluster_name}-nat-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "main" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.cluster_name}-nat-${count.index + 1}"
  }
}

# aws_route_table - Creates route tables for public and private subnets. The public route table directs traffic to the Internet Gateway, while the private route tables direct traffic to the NAT Gateways.

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.cluster_name}-public"
  }
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "${var.cluster_name}-private-${count.index + 1}"
  }
}

# aws_route_table_association - Associates the route tables with the respective subnets. Public subnets are associated with the public route table, while private subnets are associated with their corresponding private route tables.

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}