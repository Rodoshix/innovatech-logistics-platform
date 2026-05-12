output "project_name" {
  description = "Project name used for resource naming."
  value       = var.project_name
}

output "environment" {
  description = "Deployment environment."
  value       = var.environment
}

output "aws_region" {
  description = "AWS region configured for the provider."
  value       = var.aws_region
}

output "vpc_id" {
  description = "ID of the project VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet."
  value       = aws_subnet.public.id
}

output "internet_gateway_id" {
  description = "ID of the internet gateway."
  value       = aws_internet_gateway.main.id
}

output "frontend_security_group_id" {
  description = "Security group ID for frontend traffic."
  value       = aws_security_group.frontend.id
}

output "backend_security_group_id" {
  description = "Security group ID for backend traffic."
  value       = aws_security_group.backend.id
}

output "database_security_group_id" {
  description = "Security group ID for database traffic."
  value       = aws_security_group.database.id
}

output "ecr_repository_urls" {
  description = "Amazon ECR repository URLs by service."
  value = {
    for service, repository in aws_ecr_repository.services :
    service => repository.repository_url
  }
}
