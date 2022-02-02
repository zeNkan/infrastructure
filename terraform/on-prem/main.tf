variable "packer_ESXI_USERNAME" {
  type = string
}

variable "packer_ESXI_PASSWORD" {
  type = string
}

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
  esxi_hostname = "esxi1.lan.backman.fyi"
  esxi_hostport = "22"
  esxi_hostssl  = "443"
  esxi_username = var.packer_ESXI_USERNAME
  esxi_password = var.packer_ESXI_PASSWORD
}

resource "esxi_guest" "lanbros-survival" {
  guest_name = "lanbros-survival"
  disk_store = "datastore1"
  ovf_source = "../../packer/minecraft/output-baseline/minecraft.ovf"
  guestos = "centos9"

  memsize  = "12288"
  numvcpus = "4"

  network_interfaces {
    virtual_network = "VM Network"
    mac_address = "E8:49:9B:6C:A2:50"
  }
}

resource "esxi_guest" "vmtest" {
  guest_name = "terraform_test"
  disk_store = "datastore1"
  ovf_source = "../../packer/minecraft/output-baseline/minecraft.ovf"

  memsize  = "12288"
  numvcpus = "4"

  network_interfaces {
    virtual_network = "VM Network"
  }
}

