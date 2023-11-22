#resource "libvirt_volume" "debian_12" {
#  name   = "debian-12-genericcloud-amd64-20231013-1532.qcow2"
#  source = "https://cloud.debian.org/cdimage/cloud/bookworm/20231013-1532/debian-12-genericcloud-amd64-20231013-1532.qcow2"
#  pool   = "isos"
#}

resource "libvirt_volume" "ca_disk" {
  name             = "${var.resource_prefix}_ca.qcow2"
  base_volume_name = "debian-12-generic-amd64-20231013-1532.qcow2"
  base_volume_pool = "isos"
  #  base_volume_id = libvirt_volume.debian_12.id
}

resource "libvirt_cloudinit_disk" "ca_ci" {
  name      = "${var.resource_prefix}_ca_ci.iso"
  user_data = file("ca/cloudinit.yaml")
  meta_data = file("ca/metadata.yaml")
  network_config = templatefile("network.yaml", {
    ip      = cidrhost(local.lan_subnet, var.addr_ca)
    snmask  = local.lan_snmask
    gateway = local.lan_router_ip
  })
}

resource "libvirt_domain" "ca" {
  name   = "${var.resource_prefix}_ca"
  memory = "1024"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.ca_ci.id

  disk {
    volume_id = libvirt_volume.ca_disk.id
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
