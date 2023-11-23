resource "libvirt_network" "management_network" {
  name = "${var.resource_prefix}_management"
  mode = "none"

  dns { enabled = false }
}

resource "libvirt_cloudinit_disk" "management_router_ci" {
  name = "${var.resource_prefix}_management_router_ci.iso"
  user_data = templatefile("./vyos/cloudinit.cfg", {
    wan_ip   = local.wan_router_ip
    wan_mask = var.wan_snmask
    lan_ip   = local.lan_router_ip
    lan_mask = local.lan_snmask
    gateway  = var.wan_gateway

    ip_ca      = cidrhost(local.lan_subnet, var.addr_ca)
    ip_esnode0 = cidrhost(local.lan_subnet, var.addr_elastic_start)
    ip_esnode1 = cidrhost(local.lan_subnet, var.addr_elastic_start + 1)
  })
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
    mac          = "52:54:00:32:b0:b3"
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
