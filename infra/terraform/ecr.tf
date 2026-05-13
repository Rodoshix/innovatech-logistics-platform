locals {
  ecr_repositories = {
    frontend_despachos = "frontend-despachos"
    api_despachos      = "api-despachos"
    api_ventas         = "api-ventas"
  }
}

resource "aws_ecr_repository" "services" {
  for_each = local.ecr_repositories

  name         = "${local.name_prefix}-${each.value}"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-${each.value}"
    Service = each.value
  })
}
