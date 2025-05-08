terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9.0"
    }
    truenas = {
      source  = "dariusbakunas/truenas"
      version = "~> 0.11.1"
    }
  }
}
