variable "vlan_id" {
  description = "VLAN ID for the shepherdscall network"
  type        = number
}

variable "subnet" {
  description = "Subnet for the shepherdscall network"
  type        = string
}

variable "ip_prefix" {
  description = "IP prefix for the shepherdscall network (e.g., 192.168.40)"
  type        = string
}

variable "gateway" {
  description = "Gateway for the shepherdscall network"
  type        = string
}

variable "truenas_nfs_ip" {
  description = "TrueNAS NFS server IP"
  type        = string
}

variable "lxc_password" {
  description = "Password for LXC containers"
  type        = string
  sensitive   = true
}
