resource "aws_ec2_transit_gateway_route_table" "migration" {
  transit_gateway_id = data.aws_ec2_transit_gateway.this.id
  tags       = map("Name", var.tgw_rt_name)
}

resource "aws_ec2_transit_gateway_route_table_association" "VPN" {
  count               = var.num_active_tunnels/2
  transit_gateway_attachment_id  = aws_vpn_connection.avtx_gw_vpn[count.index].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.migration.id
}

resource "aws_ec2_transit_gateway_route_table_association" "hagw_VPN" {
  count               = var.num_active_tunnels/2
  transit_gateway_attachment_id  = aws_vpn_connection.avtx_hagw_vpn[count.index].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.migration.id
}
