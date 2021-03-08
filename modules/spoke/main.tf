resource "aviatrix_spoke_gateway" "spoke_gateway_aws" {
  cloud_type   = 1
  account_name = var.account
  gw_name      = var.spoke_name
  vpc_id       = var.vpc_id
  vpc_reg      = var.region
  gw_size      = var.instance_size
  ha_gw_size   = var.instance_size
  subnet       = var.cidr
  ha_subnet    = var.ha_cidr
  #  enable_snat        = false
  enable_active_mesh = true
  insane_mode        = true
  insane_mode_az     = "${var.region}a"
  ha_insane_mode_az  = "${var.region}b"
  tag_list           = var.tags
}
