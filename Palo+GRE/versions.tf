terraform {
  required_providers {
    aviatrix = {
      source = "aviatrixsystems/aviatrix"
    }
  }
  required_version = ">= 0.13"
}
provider "aws" {
  region = var.region
  # profile = var.aws_profile
}


provider "aviatrix" {
  username      = var.username
  password      = var.password
  controller_ip = var.controller_ip

  version = "~> 2.19.1"
}
