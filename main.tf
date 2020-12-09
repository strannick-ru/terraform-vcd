terraform {
  required_version = ">=0.13"
}

# Настройка провайдера для подключения к vCloud Director
provider "vcd" {
#  version              = "~> 2.6"
  user                 = var.vcd_org_user
  password             = var.vcd_org_password
  org                  = var.vcd_org_org
  vdc                  = var.vcd_org_vdc
  url                  = var.vcd_org_url
  allow_unverified_ssl = var.vcd_org_allow_unverified_ssl
  max_retry_timeout    = var.vcd_org_max_retry_timeout
}

# Создание маршрутизируемой сети
resource "vcd_network_routed" "internalRouted" {
  name         = "ApplicaNET"
  edge_gateway = var.vcd_org_edge_name
  gateway = cidrhost(var.org_net, 1)

  dhcp_pool {
    start_address = cidrhost(var.org_net, 2)
    end_address   = cidrhost(var.org_net, 100)
  }

  static_ip_pool {
    start_address = cidrhost(var.org_net, 101)
    end_address   = cidrhost(var.org_net, 254)
  }
}

resource "vcd_nsxv_snat" "applica" {
  description = "Applica test SNAT rule"

  edge_gateway = var.vcd_org_edge_name 
  network_type = "ext"
  network_name = var.vcd_org_edge_network_name

  original_address   = var.org_net
  translated_address = var.org_ext_ip

  depends_on = [vcd_network_routed.internalRouted]
}

# Создание vApp
resource "vcd_vapp" "vms" {
  name = "applica"
  power_on = "true"

  depends_on = [vcd_network_routed.internalRouted]
}

resource "vcd_vapp_org_network" "internalRouted" {
  vapp_name         = vcd_vapp.vms.name
  org_network_name  = vcd_network_routed.internalRouted.name
}