variable "region" {
  description = "The AWS region to deploy this module in"
  type        = string
}

variable "cidr" {
  description = "The CIDR range to be used for the spoke subnet"
  type        = string
}

variable "ha_cidr" {
  description = "The CIDR range to be used for the spoke ha subnet"
  type        = string
}

variable "account" {
  description = "The AWS account name, as known by the Aviatrix controller"
  type        = string
}

variable "spoke_name" {
  description = "name of the spoke gateway "
  type        = string
  default     = ""
}
variable "vpc_id" {
  description = "vpc id where spoke gets deployed"
  type        = string

}
variable "tags" {
  description = "Tags for gateway"
  type        = list
  default     = []
}
variable "instance_size" {
  description = "AWS Instance size for the Aviatrix gateways"
  type        = string
  default     = "t3.large"
}
