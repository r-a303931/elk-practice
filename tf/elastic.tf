resource "libvirt_volume" "elastic_disk" {
  name             = "${var.resource_prefix}_esnode.${count.index}.qcow2"
  base_volume_name = ""
  base_volume_pool = "isos"
  count            = var.count_elastic_nodes
}

resource "libvirt_cloudinit_disk" "elastic_ci" {
  name  = "${var.resource_prefix}_esnode_ci.${count.index}.iso"
  count = var.count_elastic_nodes
}
