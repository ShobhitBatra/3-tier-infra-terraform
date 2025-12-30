output "vpc_id" {
  value       = aws_vpc.vpc_main.id
  description = "ID of the main VPC"
}

output "public_subnet_ids" {
  value       = [aws_subnet.subnet_public_infra_a.id, aws_subnet.subnet_public_infra_b.id]
  description = "IDs of public subnets"
}

output "private_subnet_ids" {
  value = [
    aws_subnet.subnet_private_web_a.id,
    aws_subnet.subnet_private_web_b.id,
    aws_subnet.subnet_private_app_a.id,
    aws_subnet.subnet_private_app_b.id,
    aws_subnet.subnet_private_db_a.id,
    aws_subnet.subnet_private_db_b.id
  ]
  description = "IDs of all private subnets (web, app, db)"
}
