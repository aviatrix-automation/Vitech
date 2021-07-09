
variable username {}
variable password {}
variable controller_ip {}
variable name {}
variable firenet_vpc {}
variable firenet_gw {}
variable kms_key_id {}
variable ami {}
variable keypair {}
variable instance_size {}

variable additional_tags {
  description = "Additional tags for resource"
  type        = map(string)
}

variable region {
  type    = string
  default = "us-east-1"
}

variable "num" {
  type    = number
  default = 2
}

variable "vpc-subnet-id" {}

variable "az1-2" {}

variable "az" {}
