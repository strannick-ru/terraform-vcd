# Создание виртуальной машины vm1 в vApp

locals {
  ip            = cidrhost(var.org_net, 101)
  gateway_ip    = cidrhost(var.org_net, 1)
  name          = "vm1"
  memory        = 1024
  cpus          = 2
  cpu_cores     = 1
}

data "template_cloudinit_config" "vm" {
  gzip          = true
  base64_encode = true

  part {
    content_type  = "text/cloud-config"
    content       = templatefile("${path.module}/cloudinits/applica-vm.tpl", {
    vm_ip         = local.ip
    vm_gateway_ip = local.gateway_ip
    })
  }
}

# Не забывай поправить vcd_vapp_vm

resource "vcd_vapp_vm" "vm1" {
  vapp_name     = vcd_vapp.vms.name
  name          = local.name
  catalog_name  = var.vcd_org_catalog
  template_name = var.template_vm
  memory        = local.memory
  cpus          = local.cpus
  cpu_cores     = local.cpu_cores

  depends_on = [vcd_network_routed.internalRouted, vcd_vapp.vms]

  network {
    type               = "org"
    name               = vcd_network_routed.internalRouted.name
    ip                 = local.ip
    ip_allocation_mode = "MANUAL"
  }

  guest_properties = {
    "instance-id" = local.name
    "hostname"    = local.name
    "user-data"   = data.template_cloudinit_config.vm.rendered
  }

  customization {
    enabled = true
  }
}

resource "vcd_nsxv_dnat" "vm1" {
  description = "Applica vm1 DNAT rule"

  edge_gateway = var.vcd_org_edge_name
  network_type = "ext"
  network_name = var.vcd_org_edge_network_name

  enabled = true 
  logging_enabled = false

  original_address   = var.org_ext_ip
  original_port      = 22 

  translated_address = local.ip
  translated_port    = 22  

  protocol           = "tcp"

  depends_on = [vcd_network_routed.internalRouted]
}

resource "vcd_nsxv_firewall_rule" "rule-vm1" {
  name = "ApplicaFW"
  edge_gateway = var.vcd_org_edge_name

  source {
    gateway_interfaces = ["external"]
  }

  destination {
    ip_addresses = [var.org_ext_ip]
  }

  service {
    protocol = "icmp"
  }

  service {
    protocol = "tcp"
    port     = "22"
  }
}