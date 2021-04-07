ctrl_ip = "X.X.X.X"
username      = "admin"
password      = "XXXXXXXXXXX"
region        = "us-east-1"
allowed_account_id = "123456"

# Assumption is that both AWS TGW and Aviatrix Transit GW already exists
avtx_gw_bgp_asn = "65001"
aws_tgw_asn     = "64512"
avtx_gw_ip_address = "1.2.3.4"
avtx_hagw_ip_address = "5.6.7.8"
transit_vpc_id = "vpc-1234"
aviatrix_transit_gateway_name = "edge-01-east"
tgw_rt_name = "new_tgw_rt"

# Approx throughput with 16 active tunnels is 24Gbps
# (128 flows, 4 pairs of iperf3 EC2s, 2 pairs per AZ)
num_active_tunnels = 16
