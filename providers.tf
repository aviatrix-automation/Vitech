
# provider "aws" {
#   region  = local.region
#   profile = ""
# }


terraform {
  required_version = ">= 0.13"
  required_providers {

    aviatrix = {
      source  = "AviatrixSystems/aviatrix"
      version = "2.18.0"
    }
  }
}
provider "aviatrix" {
  controller_ip = ""
  username      = "admin"
  password      = "$"

}
