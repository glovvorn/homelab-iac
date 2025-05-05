variable "vlan_id" {
  description = "VLAN ID for the management network"
  type        = number
}

variable "subnet" {
  description = "Subnet for the management network"
  type        = string
}

variable "ip_prefix" {
  description = "IP prefix for the management LXC network"
  type        = string
}

variable "gateway" {
  description = "Gateway for the management network"
  type        = string
}

variable "lxc_password" {
  description = "Password for LXC containers"
  type        = string
  sensitive   = true
}
