variable "aws_region" {
  description = "AWS region where the platform infrastructure is deployed."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Base name used to identify project resources."
  type        = string
  default     = "innovatech-logistics"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the project VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.20.1.0/24"
}
