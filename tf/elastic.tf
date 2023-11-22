resource "libvirt_volume" "elastic_disk" {
  name             = "${var.resource_prefix}_esnode.${count.index}.qcow2"
  base_volume_name = ""
  base_volume_pool = "isos"
  count            = var.count_elastic_nodes
}

resource "libvirt_cloudinit_disk" "elastic_ci" {
  name      = "${var.resource_prefix}_esnode_ci.${count.index}.iso"
  user_data = templatefile("elastic/cloudinit.yaml", { index = count.index })
  meta_data = templatefile("elastic/metadata.yaml", { index = count.index })
  network_config = templatefile("network.yaml", {
    ip      = cidrhost(local.lan_subnet, var.addr_elastic_start + count.index),
    snmask  = local.lan_snmask
    gateway = local.lan_router_ip
  })
  count = var.count_elastic_nodes
}

resource "libvirt_domain" "elastic_node" {
  name   = "${var.resource_prefix}_esnode${count.index}"
  memory = "8192"
  vcpu   = 4

  count = var.count_elastic_nodes

  cloudinit = libvirt_cloudinit_disk.elastic_ci[count.index].id

  disk {
    volume_id = libvirt_volume.elastic_disk[count.index].id
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
