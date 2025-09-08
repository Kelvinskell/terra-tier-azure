# Locals block for tags
locals {
  module_tags = merge(
    var.common_tags,
    { Env = var.env } 
  )
}