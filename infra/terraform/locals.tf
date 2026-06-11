locals {
  name_prefix = "${var.project_name}-${var.environment}"
  eks_name    = "${local.name_prefix}-eks"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
