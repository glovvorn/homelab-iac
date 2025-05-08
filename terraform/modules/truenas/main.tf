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

  pool     = "data"
  name     = each.value.name
  parent   = each.value.parent
  comments = "${each.key} dataset by Terraform"

  depends_on = [truenas_dataset.parent_datasets]

  #   lifecycle {
  #     prevent_destroy = true
  #   }
}

resource "truenas_share_nfs" "nfs" {
  for_each = { for ds in var.datasets : ds.key => ds }

  paths = [
    each.value.path,
  ]
  comment = "${each.key} NFS share"
  hosts   = each.value.nfs_hosts
  networks = [
    "<optional allowed network in cidr notation>",
  ]
  alldirs = false
  enabled = true
  quiet   = false
  ro      = false
}
