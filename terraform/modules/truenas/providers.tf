terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9.0"
    }
    truenas = {
      source  = "glovvorn/truenas"
      version = "0.12.0"
    }
  }
}
