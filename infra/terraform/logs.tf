locals {
  log_groups = {
    frontend_despachos = "frontend-despachos"
    api_despachos      = "api-despachos"
    api_ventas         = "api-ventas"
  }
}

resource "aws_cloudwatch_log_group" "services" {
  for_each = local.log_groups

  name              = "/ecs/${local.name_prefix}/${each.value}"
  retention_in_days = 7

  tags = merge(local.common_tags, {
    Name    = "/ecs/${local.name_prefix}/${each.value}"
    Service = each.value
  })
}
