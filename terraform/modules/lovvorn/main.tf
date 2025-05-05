locals {
  services = {
    nextcloud = {
      vmid       = 200
      ip_suffix  = "100"
      ip         = "${var.ip_prefix}.${local.services.nextcloud.ip_suffix}"
      network_ip = "${var.ip_prefix}.${local.services.nextcloud.ip_suffix}/24"
      nfs_path   = "/mnt/data/lovvorn/nextcloud"
    }
    # Add more services here, e.g.:
    # immich = {
    #   ip_suffix = "101"
    #   nfs_path  = "/mnt/data/lovvorn/immich"
    # }
    # plex = {
    #   ip_suffix = "102"
    #   nfs_path  = "/mnt/data/lovvorn/plex"
    # }
  }
}

resource "proxmox_lxc" "nextcloud" {
  vmid         = local.services.nextcloud.vmid
  hostname     = "lovvorn-nextcloud"
  ostemplate   = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.gz"
  password     = var.lxc_password
  unprivileged = true
  start        = true
  memory       = 2048
  cores        = 2
  rootfs {
    storage = "local-lvm"
    size    = "8G"
  }
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = local.services.nextcloud.network_ip
    gw     = var.gateway
  }
}

output "services" {
  value = {
    nextcloud = {
      vmid     = proxmox_lxc.nextcloud.vmid
      ip       = local.services.nextcloud.ip
      nfs_path = local.services.nextcloud.nfs_path
    }
  }
}
