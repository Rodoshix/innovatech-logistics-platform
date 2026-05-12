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
