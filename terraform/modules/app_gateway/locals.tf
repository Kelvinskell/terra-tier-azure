# Locals block for tags
locals {
  module_tags = merge(
    var.common_tags,
    { Env = var.env } 
  )
}

locals {
  backend_address_pool_name      = "${var.vnet_name}-be-addr-pool"
  frontend_port_name             = "${var.vnet_name}-fe-port-name"
  frontend_ip_configuration_name = "${var.vnet_name}-fe-ip-config"
  http_setting_name              = "${var.vnet_name}-be-http-setting"
  listener_name                  = "${var.vnet_name}-http-lstn"
  request_routing_rule_name      = "${var.vnet_name}-rq-rt-rule"
}