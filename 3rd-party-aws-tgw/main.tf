provider "aws" {
  region = var.region
}

provider "aviatrix" {
  controller_ip = var.ctrl_ip
  username      = var.username
  password      = var.password
  version       = "2.17"
}

resource "aws_customer_gateway" "avtx_gw" {
  bgp_asn    = var.avtx_gw_bgp_asn
  ip_address = var.avtx_gw_ip_address
  type       = "ipsec.1"
  tags       = map("Name", "avtx_gw")
}

resource "aws_customer_gateway" "avtx_hagw" {
  bgp_asn    = var.avtx_gw_bgp_asn
  ip_address = var.avtx_hagw_ip_address
  type       = "ipsec.1"
  tags       = map("Name", "avtx_hagw")
}

resource "aws_vpn_connection" "avtx_gw_vpn" {
  count               = var.num_active_tunnels/2
  customer_gateway_id = aws_customer_gateway.avtx_gw.id
  type                = "ipsec.1"
  transit_gateway_id  = data.aws_ec2_transit_gateway.this.id
  static_routes_only  = var.static_routes_only
  tags                = map("Name", "avtx_gw_${count.index}")
}

resource "aws_vpn_connection" "avtx_hagw_vpn" {
  count               = var.num_active_tunnels/2
  customer_gateway_id = aws_customer_gateway.avtx_hagw.id
  type                = "ipsec.1"
  transit_gateway_id  = data.aws_ec2_transit_gateway.this.id
  static_routes_only  = var.static_routes_only
  tags                = map("Name", "avtx_hagw_${count.index}")
}

# Create an Aviatrix Transit External Device Connection
resource "aviatrix_transit_external_device_conn" "conn1" {
  count                  = var.num_active_tunnels/2
  vpc_id                 = var.transit_vpc_id
  connection_name        = "avtx_conn1_${count.index}"
  gw_name                = var.aviatrix_transit_gateway_name
  connection_type        = "bgp"
  bgp_local_as_num       = var.avtx_gw_bgp_asn
  bgp_remote_as_num      = aws_vpn_connection.avtx_gw_vpn[count.index].tunnel1_bgp_asn
  remote_gateway_ip      = "${aws_vpn_connection.avtx_gw_vpn[count.index].tunnel1_address},${aws_vpn_connection.avtx_hagw_vpn[count.index].tunnel1_address}"
  pre_shared_key         = "${aws_vpn_connection.avtx_gw_vpn[count.index].tunnel1_preshared_key},${aws_vpn_connection.avtx_hagw_vpn[count.index].tunnel1_preshared_key}"
  local_tunnel_cidr      = "${aws_vpn_connection.avtx_gw_vpn[count.index].tunnel1_cgw_inside_address}/30,${aws_vpn_connection.avtx_hagw_vpn[count.index].tunnel1_cgw_inside_address}/30"
  remote_tunnel_cidr     = "${aws_vpn_connection.avtx_gw_vpn[count.index].tunnel1_vgw_inside_address}/30,${aws_vpn_connection.avtx_hagw_vpn[count.index].tunnel1_vgw_inside_address}/30"
  custom_algorithms      = true
  phase_1_authentication = "SHA-256"
  phase_2_authentication = "HMAC-SHA-256"
  phase_1_dh_groups      = "14"
  phase_2_dh_groups      = "14"
  phase_1_encryption     = "AES-256-CBC"
  phase_2_encryption     = "AES-256-CBC"
  lifecycle {
    ignore_changes = [
      remote_gateway_ip, custom_algorithms
    ]
  }
}

resource "aviatrix_transit_external_device_conn" "conn2" {
  count                  = var.num_active_tunnels/2
  vpc_id                 = var.transit_vpc_id
  connection_name        = "avtx_conn2_${count.index}"
  gw_name                = var.aviatrix_transit_gateway_name
  connection_type        = "bgp"
  bgp_local_as_num       = var.avtx_gw_bgp_asn
  bgp_remote_as_num      = aws_vpn_connection.avtx_gw_vpn[count.index].tunnel1_bgp_asn
  remote_gateway_ip      = "${aws_vpn_connection.avtx_gw_vpn[count.index].tunnel2_address},${aws_vpn_connection.avtx_hagw_vpn[count.index].tunnel2_address}"
  pre_shared_key         = "${aws_vpn_connection.avtx_gw_vpn[count.index].tunnel2_preshared_key},${aws_vpn_connection.avtx_hagw_vpn[count.index].tunnel2_preshared_key}"
  local_tunnel_cidr      = "${aws_vpn_connection.avtx_gw_vpn[count.index].tunnel2_cgw_inside_address}/30,${aws_vpn_connection.avtx_hagw_vpn[count.index].tunnel2_cgw_inside_address}/30"
  remote_tunnel_cidr     = "${aws_vpn_connection.avtx_gw_vpn[count.index].tunnel2_vgw_inside_address}/30,${aws_vpn_connection.avtx_hagw_vpn[count.index].tunnel2_vgw_inside_address}/30"
  custom_algorithms      = true
  phase_1_authentication = "SHA-256"
  phase_2_authentication = "HMAC-SHA-256"
  phase_1_dh_groups      = "14"
  phase_2_dh_groups      = "14"
  phase_1_encryption     = "AES-256-CBC"
  phase_2_encryption     = "AES-256-CBC"
  lifecycle {
    ignore_changes = [
      remote_gateway_ip, custom_algorithms
    ]
  }
}

#############################################

data "aws_ec2_transit_gateway" "this" {
  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "owner-id"
    values = [var.allowed_account_id]
  }

  filter {
    name   = "options.amazon-side-asn"
    values = [var.aws_tgw_asn]
  }
}
