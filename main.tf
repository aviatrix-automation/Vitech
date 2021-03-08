module "transit_firenet" {
  source           = "./modules/transit-firenet"
  name             = "IR-Firenet"
  gw_name          = "Firenet-Transit-Gw"
  fw1_name         = "va-pan-fw1"
  fw2_name         = "va-pan-fw2"
  instance_size    = "c5n.4xlarge"
  fw_instance_size = "m5.xlarge"
  cidr             = "10.1.10.0/20"
  region           = "eu-west-1"
  account          = "AWS-AVX"
  firewall_image   = "Palo Alto Networks VM-Series Next-Generation Firewall (BYOL)"
  encrypt          = true
  kms_id           = "bf3c3cbf-bf27-41c7-b390-6197fd7c628e"
  insane_mode      = true
  prefix           = false
  suffix           = false
  tags = [
    "test:value1",
    "test2:value2",
    "test3:value3",
  ]
}

# output "test" {
#   value = module.transit_firenet
# }

module "spoke" {
  source        = "./modules/spoke"
  account       = "AWS-AVX"
  spoke_name    = "spoke-gw"
  vpc_id        = "vpc-0cbccf1fb3046f9b0"
  region        = "eu-west-1"
  instance_size = "c5n.xlarge"
  cidr          = "172.30.0.128/26"
  ha_cidr       = "172.30.0.192/26"
  tags = [
    "test:value1",
    "test2:value2",
    "test3:value3",
  ]
}
