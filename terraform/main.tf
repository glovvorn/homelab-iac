terraform {
  backend "local" {
    path = "/mnt/terraform-state/homelab.tfstate"
  }

  required_providers {
    unifi = {
      source  = "paultyng/unifi"
      version = "~> 0.41.0"
    }
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9.0"
    }
    truenas = {
      source  = "dariusbakunas/truenas"
      version = "~> 0.11.0"
    }
  }
}

provider "unifi" {
  username       = var.unifi_username
  password       = var.unifi_password
  api_url        = "https://${var.udm_ip}:443"
  allow_insecure = true
}

provider "proxmox" {
  pm_api_url          = "https://${var.proxmox_ip}:8006/api2/json/"
  pm_api_token_id     = var.proxmox_api_token_id     # or rely on PM_API_TOKEN_ID env
  pm_api_token_secret = var.proxmox_api_token_secret # or rely on PM_API_TOKEN_SECRET env
  pm_tls_insecure     = true
}

provider "truenas" {
  api_key  = var.truenas_api_key
  base_url = "https://${var.truenas_nfs_ip}:443/api/v2.0"
}

# VLAN Configuration
resource "unifi_network" "vlans" {
  for_each = local.network_configs

  name    = each.value.name
  purpose = "vlan-only"
  vlan_id = each.value.vlan_id
  subnet  = each.value.subnet
}

###############################################################################
# 1. Family Devices Group (Laptops, Phones, Consoles, Smart TVs, etc.)
###############################################################################
resource "unifi_user_group" "personal_devices_group" {
  name              = "Personal-Devices"
  qos_rate_max_down = 50000 # max download (kbps)
  qos_rate_max_up   = 10000 # max upload   (kbps)
}

###############################################################################
# 2. IoT Devices Group (Doorbells, Smart Outlets, Appliances)
###############################################################################
resource "unifi_user_group" "iot_group" {
  name              = "IoT-Devices"
  qos_rate_max_down = 5000 # low bandwidth for sensors
  qos_rate_max_up   = 2000
}

###############################################################################
# 3. Guest Group
###############################################################################
resource "unifi_user_group" "guest_group" {
  name              = "Guest-Network"
  qos_rate_max_down = 10000 # moderate guest speeds
  qos_rate_max_up   = 5000
}

# WiFi Networks for VLANs 100, 110, 120
resource "unifi_wlan" "personal_devices" {
  name          = "Personal-Devices"
  passphrase    = var.personal_devices_passphrase
  network_id    = local.networks.personal.vlan_id
  security      = "wpapsk"
  user_group_id = unifi_user_group.personal_devices_group.id
}

resource "unifi_wlan" "iot" {
  name          = "IoT"
  passphrase    = var.iot_passphrase
  network_id    = local.networks.iot.vlan_id
  security      = "wpapsk"
  user_group_id = unifi_user_group.iot_group.id
}

resource "unifi_wlan" "guest" {
  name          = "Guest"
  passphrase    = var.guest_passphrase
  network_id    = local.networks.guest.vlan_id
  security      = "wpapsk"
  is_guest      = true
  user_group_id = unifi_user_group.guest_group.id
}


# Modules
module "management" {
  source       = "./modules/management"
  vlan_id      = local.network_configs.management.vlan_id
  subnet       = local.network_configs.management.subnet
  ip_prefix    = local.network_configs.management.ip_prefix
  gateway      = local.network_configs.management.gateway
  lxc_password = var.lxc_password
}

module "lovvorn" {
  source         = "./modules/lovvorn"
  vlan_id        = local.network_configs.lovvorn.vlan_id
  subnet         = local.network_configs.lovvorn.subnet
  ip_prefix      = local.network_configs.lovvorn.ip_prefix
  gateway        = local.network_configs.lovvorn.gateway
  truenas_nfs_ip = var.truenas_nfs_ip
  lxc_password   = var.lxc_password
}

module "shepherdscall" {
  source         = "./modules/shepherdscall"
  vlan_id        = local.network_configs.shepherdscall.vlan_id
  subnet         = local.network_configs.shepherdscall.subnet
  ip_prefix      = local.network_configs.shepherdscall.ip_prefix
  gateway        = local.network_configs.shepherdscall.gateway
  truenas_nfs_ip = var.truenas_nfs_ip
  lxc_password   = var.lxc_password
}

module "truenas" {
  source = "./modules/truenas"
  datasets = concat(
    [
      for service_name, service in module.lovvorn.services : {
        name      = "lovvorn/${service.service_name}"
        path      = service.nfs_path
        nfs_hosts = [service.ip]
      } if service.nfs_path != null
    ],
    [
      for service_name, service in module.shepherdscall.services : {
        name      = "shepherdscall/${service.service_name}"
        path      = service.nfs_path
        nfs_hosts = [service.ip]
      } if service.nfs_path != null
    ]
  )
}

# Outputs for Ansible
output "lxc_inventory" {
  value = {
    management = {
      services = {
        management = {
          vmid = module.management.management_vmid
          ip   = module.management.management_ip
        }
      }
    }
    lovvorn = {
      services = {
        for service_name, service in module.lovvorn.services : service_name => {
          vmid = service.vmid
          ip   = service.ip
        }
      }
    }
    shepherdscall = {
      services = {
        for service_name, service in module.shepherdscall.services : service_name => {
          vmid = service.vmid
          ip   = service.ip
        }
      }
    }
  }
}

# Output for Docker Compose NFS Paths
output "nfs_paths" {
  value = {
    lovvorn = {
      for service_name, service in module.lovvorn.services : service_name => service.nfs_path
      if service.nfs_path != null
    }
    shepherdscall = {
      for service_name, service in module.shepherdscall.services : service_name => service.nfs_path
      if service.nfs_path != null
    }
  }
}
