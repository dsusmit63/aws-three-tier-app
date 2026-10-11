output "vpc_id" {
  description = "ID of the application VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs mapped by Availability Zone"

  value = {
    for az, subnet in aws_subnet.public :
    az => subnet.id
  }
}

output "private_app_subnet_ids" {
  description = "Application subnet IDs mapped by AZ"

  value = {
    for az, subnet in aws_subnet.private_app :
    az => subnet.id
  }
}

output "private_db_subnet_ids" {
  description = "Database subnet IDs mapped by AZ"

  value = {
    for az, subnet in aws_subnet.private_db :
    az => subnet.id
  }
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

output "availability_zones" {
  description = "Selected Availability Zones"
  value       = local.azs
}
