resource "truenas_dataset" "datasets" {
  for_each = { for dataset in var.datasets : dataset.name => dataset }

  name = each.value.name
  pool = "storage-pool"
  path = each.value.path
}

resource "truenas_share_nfs" "nfs_shares" {
  for_each = { for dataset in var.datasets : dataset.name => dataset }

  path    = truenas_dataset.datasets[each.key].path
  enabled = true
  hosts   = each.value.nfs_hosts
}
