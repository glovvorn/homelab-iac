resource "truenas_dataset" "datasets" {
  for_each = { for ds in var.datasets : ds.name => ds }

  pool = "data"          # the ZFS pool name
  name = each.value.name # the dataset name within that pool

  lifecycle {
    prevent_destroy = true # Prevent accidental deletion
  }
}

resource "truenas_share_nfs" "nfs_shares" {
  for_each = { for ds in var.datasets : ds.name => ds }

  paths = [
    each.value.path
  ]
  hosts = each.value.nfs_hosts
}
