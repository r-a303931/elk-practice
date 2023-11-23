resource "local_file" "ansible_inventory" {
  filename = "../ansible/inventory"
  content = templatefile("./inventory.tftpl", {
    lan_subnet         = local.lan_subnet,
    addr_elastic_start = var.addr_elastic_start,
    ca_ip              = cidrhost(local.lan_subnet, var.addr_ca),
    esnodes            = libvirt_domain.elastic_node.*.name
  })
}
