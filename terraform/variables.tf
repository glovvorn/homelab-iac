variable "unifi_username" {
  description = "UniFi controller username"
  type        = string
  sensitive   = true
}

variable "unifi_password" {
  description = "UniFi controller password"
  type        = string
  sensitive   = true
}

variable "udm_ip" {
  description = "UDM Pro SE IP address"
  type        = string
}

variable "proxmox_password" {
  description = "Proxmox API password"
  type        = string
  sensitive   = true
}

variable "truenas_api_key" {
  description = "TrueNAS API key"
  type        = string
  sensitive   = true
}

variable "truenas_nfs_ip" {
  description = "TrueNAS NFS server IP"
  type        = string
}

variable "personal_devices_passphrase" {
  description = "WiFi passphrase for Personal-Devices WLAN"
  type        = string
  sensitive   = true
}

variable "iot_passphrase" {
  description = "WiFi passphrase for IoT WLAN"
  type        = string
  sensitive   = true
}

variable "guest_passphrase" {
  description = "WiFi passphrase for Guest WLAN"
  type        = string
  sensitive   = true
}

variable "lxc_password" {
  description = "Password for LXC containers"
  type        = string
  sensitive   = true
}
