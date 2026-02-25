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

## Public Subnet
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

## Private Subnet
## Internet Gateway
## NAT Gateway
## Route tables
## Route Table Association

