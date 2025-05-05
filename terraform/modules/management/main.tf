locals {
    ip = "${var.ip_prefix}.10"
    network_ip = "${var.ip_prefix}.10/24"
}

resource "proxmox_lxc" "management" {
  vmid         = 100
  hostname     = "management"
  ostemplate   = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  password     = var.lxc_password
  unprivileged = true
  start        = true
  memory       = 4096
  cores        = 2
  rootfs {
    storage = "local-lvm"
    size    = "8G"
  }
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = local.network_ip
    gw     = var.gateway
  }
}

output "management_vmid" {
  value = proxmox_lxc.management.vmid
}

output "management_ip" {
  value = local.ip
}

output "services" {
  value = {
    management = {
      vmid     = proxmox_lxc.management.vmid
      ip       = local.ip
      nfs_path = null
    }
  }
}