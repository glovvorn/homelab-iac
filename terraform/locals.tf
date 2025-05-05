locals {
  networks = {
    management = {
      name    = "management"
      vlan_id = 10
      services = {
        pihole     = { nfs_path = null }
        traefik    = { nfs_path = null }
        monitoring = { nfs_path = null }
      }
    }
    storage = {
      name     = "storage"
      vlan_id  = 20
      services = {}
    }
    lovvorn = {
      name     = "lovvorn"
      vlan_id  = 30
      services = {} # Defined in module
    }
    shepherdscall = {
      name     = "shepherdscall"
      vlan_id  = 40
      services = {} # Defined in module
    }
    personal = {
      name     = "LovvMyWifi"
      vlan_id  = 100
      services = {}
    }
    iot = {
      name     = "LovvIoT"
      vlan_id  = 110
      services = {}
    }
    guest = {
      name     = "LovvOurGuests"
      vlan_id  = 120
      services = {}
    }
  }

  # Generate network attributes dynamically
  network_configs = {
    for name, network in local.networks : name => merge(network, {
      ip_prefix = "192.168.${network.vlan_id}"
      subnet    = "192.168.${network.vlan_id}.0/24"
      gateway   = "192.168.${network.vlan_id}.1"
    })
  }
}
