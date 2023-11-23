terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
  }
}


provider "libvirt" {
  uri = "qemu+ssh://arioux@pluto.infra.arioux.org/system"
}


variable "resource_prefix" {
  type    = string
  default = "elkpractice"
}

variable "wan_gateway" {
  type    = string
  default = "192.168.136.1"
}

variable "wan_snmask" {
  type    = number
  default = 22
}

variable "wan_host_num" {
  type    = number
  default = 49
}

variable "lan_subnet_extension" {
  type    = number
  default = 6
}

variable "lan_subnet_number" {
  type    = number
  default = 18
}

variable "addr_router" {
  type    = number
  default = 1
}

variable "addr_ca" {
  type    = number
  default = 2
}

variable "addr_elastic_start" {
  type    = number
  default = 3
}

variable "count_elastic_nodes" {
  type    = number
  default = 2
}

locals {
  wan_router_ip = cidrhost("${var.wan_gateway}/${var.wan_snmask}", var.wan_host_num)

  lan_subnet = cidrsubnet("${var.wan_gateway}/${var.wan_snmask}", var.lan_subnet_extension, var.lan_subnet_number)
  lan_snmask = var.wan_snmask + var.lan_subnet_extension

  lan_router_ip = cidrhost(local.lan_subnet, var.addr_router)
}
