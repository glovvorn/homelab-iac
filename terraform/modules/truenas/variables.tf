variable "datasets" {
  description = "List of datasets and NFS configurations"
  type = list(object({
    name      = string
    path      = string
    nfs_hosts = list(string)
  }))
}
