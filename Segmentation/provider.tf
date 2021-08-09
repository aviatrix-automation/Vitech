# Specify Aviatrix as the provider with these parameters:
# source - path to Aviaatrix Terraform provider in the terraform registry
# version - release version # of Aviatrix Terraform provider
terraform {
  required_providers {
    aviatrix = {
      source = "AviatrixSystems/aviatrix"
      version = "2.19.5"

    }
  }
}
# Specify Aviatrix controller detail inside the provider block:
# controller_ip - public IP address of the controller
# username - login user name, default is admin
# password - password
provider "aviatrix" {
    controller_ip = ""
    username = "admin"
    password = ""
}