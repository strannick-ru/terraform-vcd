terraform {
  required_providers {
    vcd = {
      source = "vmware/vcd"
    }
    template = {
      source = "hashicorp/template"
    }
  }
  required_version = ">= 0.13"
}
