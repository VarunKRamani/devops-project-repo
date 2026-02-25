# VPC Module Code Explanation.

In this we will explore the VPC code and different modules used for creation of VPC. 

## VPC main module
- This is the main VPC resource from which the VPC creation is done using the CIDR block specified in `var.vpc_cidr`.
- It enables DNS support and DNS hostnames for instances in the VPC.
- Adds tags for kubernetes cluster integration and identification.
```hcl
resource "aws_vpc" "main" {
  cidr_block             = var.vpc_cidr
  enable_dns_hostnames   = true
  enable_dns_support     = true

  tags = {
  Name                                         = "${var.cluster_name}-vpc"
  "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
  }
}
```

## Private Subnet
- Creates multiple private subnets based on `private_subnet_cidrs`.
- Each subnet is assigned on avilability zone from `availability_zones`
- Tags define kubernetes cluster association and internal load balancer role.
```hcl
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
```

## Public Subnet
- Creates Multiple public subnets based on `public_subnet_cidrs`.
- Assigns public IP addresses to instamce on launch.
- Tags specific Kubernetes cluster association and public load balancer role.
```hcl
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
```

## Internet Gateway
- Creates an Internet Gateway to enables inyernet access for public subnet
```hcl
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.cluster_name}-igw"
  }
}
```

## NAT Gateway and Elastic IP
- Elastic Ip are creted for the NAT Gateways
- NAT Gateways allow private subnet instances to access the internet securely
- Each NAT gateway is aasociated with a public subnet.
```hcl
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
```
## Route tables
- Public route table routes internet traffic (0.0.0.0/0) to the I nternett Gateway.
```hcl
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
```
- Private route table route internet traffic through NAT Gateways.
```hcl
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
```

## Route Table Association
- Associates each private subnet with a private route table
```hcl
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
```

- Associates all public subnet with the public route table
```hcl
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
```

