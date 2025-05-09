locals {
  shared_nfs_path = "/mnt/data/lovvorn/"
  services_base = {
    nextcloud = {
      vmid         = 200
      ip_suffix    = "100"
      service_name = "cloud"
    }
    # add more base entries as needed
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

locals {
  services = tomap({
    for name, svc in local.services_base :
    name => merge(
      svc,
      {
        ip         = "${var.ip_prefix}.${svc.ip_suffix}"
        network_ip = "${var.ip_prefix}.${svc.ip_suffix}/24"
        nfs_path   = "${local.shared_nfs_path}${svc.service_name}"
      }
    )
  })
}

resource "proxmox_lxc" "nextcloud" {
  vmid         = local.services.nextcloud.vmid
  hostname     = "lovvorn-nextcloud"
  target_node  = "pve"
  ostemplate   = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
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
  tags = "lovvorn"
}

output "services" {
  value = {
    nextcloud = {
      service_name = local.services.nextcloud.service_name
      vmid         = proxmox_lxc.nextcloud.vmid
      ip           = local.services.nextcloud.ip
      nfs_path     = local.services.nextcloud.nfs_path
    }
  }
}
