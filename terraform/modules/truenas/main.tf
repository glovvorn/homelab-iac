# Create parent datasets (lovvorn, shepherdscall)
resource "truenas_dataset" "parent_datasets" {
  for_each = toset(["lovvorn", "shepherdscall"])

  pool = "data"
  name = each.value

#   lifecycle {
#     prevent_destroy = true
#   }
}

# Create nested datasets (lovvorn/cloud, shepherdscall/cloud)
resource "truenas_dataset" "datasets" {
  for_each = { for ds in var.datasets : ds.name => ds }

  pool = "data"
  name = each.value.name

  depends_on = [truenas_dataset.parent_datasets]

#   lifecycle {
#     prevent_destroy = true
#   }
}

# Create NFS shares for nested datasets
resource "truenas_share_nfs" "nfs_shares" {
  for_each = { for ds in var.datasets : ds.name => ds }

  path    = each.value.path      # e.g., "/mnt/data/lovvorn/cloud"
  hosts   = each.value.nfs_hosts # e.g., ["192.168.10.100"]
  comment = "${each.key} NFS share"
  enabled = true
}
