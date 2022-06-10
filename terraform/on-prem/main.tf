terraform {
  required_version = ">= 0.13"
  required_providers {
    esxi = {
      source = "registry.terraform.io/josenk/esxi"
      #
      # For more information, see the provider source documentation:
      # https://github.com/josenk/terraform-provider-esxi
      # https://registry.terraform.io/providers/josenk/esxi
    }
  }
}

provider "esxi" {
  esxi_hostname = var.esxi_hostname
  esxi_hostport = var.esxi_ssh_port
  esxi_hostssl  = var.esxi_ssl_port
  esxi_username = var.esxi_username
  esxi_password = var.esxi_password
}

resource "esxi_guest" "lanbros_minecraft_119" {
  guest_name = var.mc_server_name
  disk_store = var.esxi_datastore
  ovf_source = var.mc_server_ovf_path

  memsize  = "12288"
  numvcpus = "4"

  network_interfaces {
    virtual_network = "VM Network"
    mac_address     = var.mc_server_mac
  }

  guestinfo = {
    "metadata.encoding" = "gzip+base64"
    "metadata"          = base64gzip(jsonencode({ "local-hostname" = var.mc_server_name }))
  }
}

