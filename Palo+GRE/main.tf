
#Existing Edge VPC info
data "aviatrix_vpc" "firenet_vpc" {
  name = var.firenet_vpc
}

#Existing Edge gateway info
data "aviatrix_transit_gateway" "firenet_gw" {
  gw_name = var.firenet_gw
}

############################ Security Groups ###############################

resource "aws_security_group" "fw-mgmt" {
  vpc_id = data.aviatrix_vpc.firenet_vpc.vpc_id
  name   = "${var.name}-management"
  ingress {
    protocol    = -1
    self        = false
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Only for Firewall Interface"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Only for Firewall Interface"
  }
}

resource "aws_security_group" "fw-lan" {
  vpc_id = data.aviatrix_vpc.firenet_vpc.vpc_id
  name   = "${var.name}-lan"
  ingress {
    protocol    = -1
    self        = false
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Only for Firewall Interface"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Only for Firewall Interface"
  }
}

resource "aws_security_group" "fw-egress" {
  vpc_id = data.aviatrix_vpc.firenet_vpc.vpc_id
  name   = "${var.name}-egress"
  ingress {
    protocol    = -1
    self        = false
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Only for Firewall Interface"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Only for Firewall Interface"
  }
}


resource "aws_subnet" "subnets" {
  count             = length(var.vpc-subnet-id)
  vpc_id            = data.aviatrix_vpc.firenet_vpc.vpc_id
  cidr_block        = element(var.vpc-subnet-id, count.index)
  availability_zone = element(var.az1-2, count.index)
  tags = {
    Name = "Firewall-LAN-${element(var.az, count.index)}"
  }
}

############################ ROUTE TABLE ###############################
resource "aws_route_table" "fwrt_lan" {
  count  = var.num
  vpc_id = data.aviatrix_vpc.firenet_vpc.vpc_id
  tags = {
    Name = "${var.name}-${element(var.az, count.index)}-lan-rt"
  }
}



######################### ROUTE TABLE ASSOCIATON #######################
resource "aws_route_table_association" "fwutrta" {
  count          = "2"
  subnet_id      = element(aws_subnet.subnets.*.id, count.index)
  route_table_id = element(aws_route_table.fwrt_lan.*.id, count.index)
}

resource "aws_eip" "eip-ut" {
  count = var.num
  vpc   = true
  tags = {
    Name = "${var.name}-${element(var.az, count.index)}-egress-eip"
  }
}

resource "aws_eip" "eip-mgmt" {
  count = var.num
  vpc   = true
  tags = {
    Name = "${var.name}-${element(var.az, count.index)}-management-eip"
  }
}

########################## ASSOCIATE EIP TO ENI ########################
resource "aws_eip_association" "eip-ut" {
  count                = var.num
  network_interface_id = element(aws_network_interface.fw-ut.*.id, count.index)
  allocation_id        = element(aws_eip.eip-ut.*.id, count.index)
  depends_on           = [aws_instance.fw]
}

resource "aws_eip_association" "eip-mgmt" {
  count                = var.num
  network_interface_id = element(aws_network_interface.fw-mgmt.*.id, count.index)
  allocation_id        = element(aws_eip.eip-mgmt.*.id, count.index)
}

########################## ELASTIC NETWORK INTERFACE FOR PAN ###########
resource "aws_network_interface" "fw-mgmt" {
  count             = var.num
  subnet_id         = element(data.aviatrix_vpc.firenet_vpc.subnets.*.subnet_id, count.index * 2)
  security_groups   = [aws_security_group.fw-mgmt.id]
  source_dest_check = true
  private_ips_count = 0
  description       = "${var.name}-${element(var.az, count.index)}-management"
  tags = {
    Name = "${var.name}-${element(var.az, count.index)}-management"
  }
}
resource "aws_network_interface" "fw-tr" {
  count             = var.num
  subnet_id         = element(aws_subnet.subnets.*.id, count.index)
  security_groups   = [aws_security_group.fw-lan.id]
  source_dest_check = false
  private_ips_count = 0
  description       = "${var.name}-${element(var.az, count.index)}-lan"
  tags = {
    Name = "${var.name}-${element(var.az, count.index)}-lan"
  }
}
resource "aws_network_interface" "fw-ut" {
  count             = var.num
  subnet_id         = element(data.aviatrix_vpc.firenet_vpc.subnets.*.subnet_id, (count.index * 2) + 1)
  security_groups   = [aws_security_group.fw-egress.id]
  source_dest_check = false
  private_ips_count = 0
  description       = "${var.name}-${element(var.az, count.index)}-egress"
  tags = {
    Name = "${var.name}-${element(var.az, count.index)}-egress"
  }
}

## EC2 ##  
resource "aws_instance" "fw" {
  count                   = var.num
  disable_api_termination = false
  #iam_instance_profile                 = "pan-bootstrap-s3-role"
  instance_initiated_shutdown_behavior = "stop"
  ebs_optimized                        = true
  ami                                  = var.ami
  instance_type                        = instance_size
  key_name                             = var.keypair
  monitoring                           = true
  user_data                            = "mgmt-interface-swap=enable"
  network_interface {
    device_index         = 1
    network_interface_id = element(aws_network_interface.fw-mgmt.*.id, count.index)
  }
  network_interface {
    device_index         = 0
    network_interface_id = element(aws_network_interface.fw-ut.*.id, count.index)
  }
  network_interface {
    device_index         = var.num
    network_interface_id = element(aws_network_interface.fw-tr.*.id, count.index)
  }
  ebs_block_device {
    device_name           = "/dev/xvda"
    kms_key_id            = var.kms_key_id
    encrypted             = true
    delete_on_termination = true
  }

  root_block_device {
    kms_key_id            = var.kms_key_id
    encrypted             = true
    delete_on_termination = true
  }
  lifecycle {
    ignore_changes  = [ebs_block_device, root_block_device, tags]
    prevent_destroy = false
  }
  tags = merge(
    var.additional_tags,
    {
      Name = "${var.name}-${element(var.az, count.index)}"
    },
  )
}
