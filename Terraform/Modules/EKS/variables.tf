# vpc_cidr - The CIDR block for the VPC, defined as a variable for flexibility.
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

# availability_zones - A list of availability zones to distribute the subnets across, defined as a variable for flexibility.
variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

#private_subnet_cidrs and public_subnet_cidrs - Lists of CIDR blocks for private and public subnets, respectively, defined as variables for flexibility in subnet configuration.
variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

#cluster_name - The name of the EKS cluster, used in tags for resource identification.
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}