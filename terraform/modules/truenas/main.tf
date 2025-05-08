resource "truenas_dataset" "parent_datasets" {
  for_each = toset(["lovvorn", "shepherdscall"])

  pool = "data"
  name = each.value

  #   lifecycle {
  #     prevent_destroy = true
  #   }
}

resource "truenas_dataset" "datasets" {
  for_each = { for ds in var.datasets : ds.key => ds }

  pool   = "data"
  name   = each.value.name
  parent = each.value.parent

  depends_on = [truenas_dataset.parent_datasets]

  #   lifecycle {
  #     prevent_destroy = true
  #   }
}

# Create NFS shares for nested datasets
resource "truenas_share_nfs" "nfs_shares" {
  for_each = { for ds in var.datasets : ds.key => ds }

  paths   = [each.value.path]
  hosts   = each.value.nfs_hosts # We are already passing in an array of hosts
  comment = "${each.key} NFS share"
  enabled = true
}
