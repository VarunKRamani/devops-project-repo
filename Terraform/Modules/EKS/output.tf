# vpc_id, private_subnet_ids, and public_subnet_ids - Outputs that provide the VPC ID and lists of private and public subnet IDs, respectively, for use in other modules or for reference after deployment.
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}
