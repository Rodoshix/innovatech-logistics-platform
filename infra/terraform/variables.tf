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

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets."
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets."
  type        = list(string)
  default     = ["10.20.11.0/24", "10.20.12.0/24"]
}

variable "db_instance_type" {
  description = "EC2 instance type used for the MySQL runtime."
  type        = string
  default     = "t3.micro"
}

variable "db_volume_size" {
  description = "Root volume size in GB for the MySQL EC2 instance."
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Initial MySQL database name."
  type        = string
  default     = "innovatech"
}

variable "db_username" {
  description = "Application database username."
  type        = string
  default     = "innovatech_app"
}

variable "db_password" {
  description = "Application database password."
  type        = string
  sensitive   = true
}

variable "db_root_password" {
  description = "Root password for the MySQL runtime."
  type        = string
  sensitive   = true
}

variable "key_pair_name" {
  description = "Optional EC2 key pair name for operational access."
  type        = string
  default     = null
}

variable "app_image_tag" {
  description = "Container image tag deployed by ECS."
  type        = string
  default     = "latest"
}

variable "app_desired_count" {
  description = "Number of ECS tasks to keep running."
  type        = number
  default     = 1
}

variable "app_task_cpu" {
  description = "CPU units assigned to the ECS Fargate task."
  type        = number
  default     = 1024
}

variable "app_task_memory" {
  description = "Memory in MiB assigned to the ECS Fargate task."
  type        = number
  default     = 2048
}

variable "eks_version" {
  description = "Kubernetes version used by the EKS cluster."
  type        = string
  default     = "1.30"
}

variable "eks_node_instance_types" {
  description = "EC2 instance types used by the EKS managed node group."
  type        = list(string)
  default     = ["t3.small"]
}

variable "eks_node_desired_size" {
  description = "Desired number of worker nodes in the EKS managed node group."
  type        = number
  default     = 1
}

variable "eks_node_min_size" {
  description = "Minimum number of worker nodes in the EKS managed node group."
  type        = number
  default     = 1
}

variable "eks_node_max_size" {
  description = "Maximum number of worker nodes in the EKS managed node group."
  type        = number
  default     = 2
}

variable "eks_endpoint_public_access" {
  description = "Whether the EKS Kubernetes API endpoint is reachable from the public internet."
  type        = bool
  default     = true
}

variable "eks_endpoint_private_access" {
  description = "Whether the EKS Kubernetes API endpoint is reachable from inside the VPC."
  type        = bool
  default     = true
}
