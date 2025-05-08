variable "datasets" {
  description = "List of datasets and NFS configurations"
  type = list(object({
    key       = string
    name      = string
    parent    = string
    path      = string
    nfs_hosts = list(string)
  }))
}
