variable "ctrl_ip" {
  description = "Aviatrix Controller Access IP"
  type        = string
}

variable "username" {
  description = "Aviatrix Controller username"
  type        = string
}

variable "password" {
  description = "Aviatrix Controller password"
  type        = string
}

variable "region" {
  description = "AWS Region for TGW"
  type        = string
}

variable "allowed_account_id" {
  description = "AWS account ID for which this module can be executed"
  type        = string
}

variable "avtx_gw_bgp_asn" {
  description = "The gateway's Border Gateway Protocol (BGP) Autonomous System Number (ASN)."
  type        = string
}

variable "aws_tgw_asn" {
  description = "AWS TGW's Border Gateway Protocol (BGP) Autonomous System Number (ASN)."
  type        = string
}

variable "avtx_gw_ip_address" {
  description = "IP address of the client VPN endpoint"
  type        = string
}

variable "avtx_hagw_ip_address" {
  description = "IP address of the client VPN endpoint"
  type        = string
}

variable "transit_vpc_id" {
  description = "Transit VPC ID"
  type        = string
}

variable "aviatrix_transit_gateway_name" {
  description = "Name of the Aviatrix Transit Gateway"
  type        = string
}

variable "num_active_tunnels" {
  description = "Number of active VPN tunnels"
  type        = number
}

variable "static_routes_only" {
  description = "Whether the VPN connection uses static routes exclusively. Static routes must be used for devices that don't support BGP"
  type        = bool
  default     = false
}

variable "static_routes_destinations" {
  description = "List of CIDRs to be routed into the VPN tunnel."
  type        = list
  default     = []
}

variable "tgw_rt_name" {
  description = "Name tag for the new TGW RT"
  type        = string
}
