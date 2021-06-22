provider "aviatrix" {
  controller_ip = var.ctrl_ip
  username      = var.username
  password      = var.password
  version       = "2.19.3"
}

resource "aviatrix_transit_external_device_conn" "client" {
  vpc_id                    = "vpc-0b55ba6329cb63531"
  connection_name           = ""
  gw_name                   = "client-aviatrix-transit"
  remote_gateway_ip         = ""
  connection_type           = "bgp"
  pre_shared_key            = ""
  direct_connect            = false
  bgp_local_as_num          = "65111"
  bgp_remote_as_num         = ""
  ha_enabled                = false
  local_tunnel_cidr         = ""
  remote_tunnel_cidr        = ""
  custom_algorithms         = true
  phase_1_authentication    = "SHA-384"
  phase_2_authentication    = "HMAC-SHA-384"
  phase_1_dh_groups         = "19"
  phase_2_dh_groups         = "19"
  phase_1_encryption        = "AES-256-CBC"
  phase_2_encryption        = "AES-256-CBC"
  enable_event_triggered_ha = null
  enable_ikev2              = true
}
