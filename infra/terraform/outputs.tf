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

output "ecs_app_security_group_id" {
  description = "Security group ID attached to the ECS application task."
  value       = aws_security_group.ecs_app.id
}

output "database_instance_id" {
  description = "ID of the EC2 instance running MySQL."
  value       = aws_instance.database.id
}

output "database_private_ip" {
  description = "Private IP used by application services to connect to MySQL."
  value       = aws_instance.database.private_ip
}

output "ecr_repository_urls" {
  description = "Amazon ECR repository URLs by service."
  value = {
    for service, repository in aws_ecr_repository.services :
    service => repository.repository_url
  }
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_id" {
  description = "ID of the ECS cluster."
  value       = aws_ecs_cluster.main.id
}

output "ecs_service_name" {
  description = "Name of the ECS service running the application task."
  value       = aws_ecs_service.app.name
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition."
  value       = aws_ecs_task_definition.app.arn
}

output "lab_role_arn" {
  description = "ARN of the LabRole used by ECS tasks."
  value       = data.aws_iam_role.lab.arn
}

output "cloudwatch_log_group_names" {
  description = "CloudWatch log group names by service."
  value = {
    for service, log_group in aws_cloudwatch_log_group.services :
    service => log_group.name
  }
}
