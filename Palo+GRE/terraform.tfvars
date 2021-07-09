# aws_profile            = "default"
region = ""
controller_ip = "" # Created in another TF
username      = ""          # Created in another TF with the controller
password      = ""  # Created in another TF with the controller

name = "" #name of the firewall
firenet_vpc = ""
firenet_gw = ""
instance_size = ""
kms_key_id = "" 
ami = ""
keypair = ""
vpc-subnet-id = ["10.x.x.0/28","10.x.x.16/28"]
az1-2 = ["eu-west-1a","eu-west-1b"]
additional_tags = {
    Environment = "Test"
    Product     = "Aviatrix"
}
az = ["a","b"]
