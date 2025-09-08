# Locals block for tags
locals {
  module_tags = merge(
    var.common_tags,
    { Env = var.env } 
  )
}

# Create locals block for subnets
locals {
  public_subnets = {
    "public-subnet-1" = "10.0.0.0/27"
    "public-subnet-2" = "10.0.0.32/27"
  }

  private_subnets = {
    "private-subnet-1" = "10.0.0.64/27"
    "private-subnet-2" = "10.0.0.96/27"
  }

  database_subnets = {
    "database-subnet-1" = "10.0.0.128/27"
    "database-subnet-2" = "10.0.0.160/27"
  }
}