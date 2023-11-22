terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
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

resource "libvirt_network" "management_network" {
  name = "${var.resource_prefix}_management"
  mode = "none"

  dns { enabled = false }
}

resource "libvirt_cloudinit_disk" "management_router_ci" {
  name      = "${var.resource_prefix}_management_router_ci.iso"
  user_data = file("./vyos/cloudinit.cfg")
}

resource "libvirt_domain" "vyos_router" {
  name   = "${var.resource_prefix}_management_router"
  memory = "1024"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.management_router_ci.id

  disk {
    url = "https://share.arioux.org/d041d772-e10b-48fb-99ac-0e6211be3d90/vyos-1.3-rolling-202311221016-amd64.iso"
  }

  network_interface {
    network_name = "ccdc"
  }

  network_interface {
    network_id = libvirt_network.management_network.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
