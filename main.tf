provider "ibm" {
  softlayer_username = var.softlayer_username
  softlayer_api_key  = var.softlayer_api_key
  ibmcloud_api_key   = var.ibmcloud_api_key
  generation = 2
}

resource "random_id" "name1" {
  byte_length = 2
}

resource "random_id" "name2" {
  byte_length = 2
}

resource "random_pet" "cluster_name" {}

locals {
  ZONE1 = "${var.region}-1"
  ZONE2 = "${var.region}-2"
  ZONE3 = "${var.region}-3"
}

resource "ibm_is_vpc_address_prefix" "vpc1_address_prefix-zone1" {
  name = "prefix1"
  zone   = local.ZONE1
  vpc         = ibm_is_vpc.vpc1.id
  cidr        = "${var.zone1_prefix}/18"
}

resource "ibm_is_vpc_address_prefix" "vpc1_address_prefix-zone2" {
  name = "prefix2"
  zone   = local.ZONE2
  vpc         = ibm_is_vpc.vpc1.id
  cidr        = "${var.zone2_prefix}/18"
}

resource "ibm_is_vpc_address_prefix" "vpc1_address_prefix-zone3" {
  name = "prefix3"
  zone   = local.ZONE3
  vpc         = ibm_is_vpc.vpc1.id
  cidr        = "${var.zone3_prefix}/18"
}


resource "ibm_is_vpc" "vpc1" {
  name                      = "vpc-${random_pet.cluster_name.id}"
  address_prefix_management = "manual"
}

resource "ibm_is_public_gateway" "subnet1_gateway" {
    name = "${ibm_is_vpc.vpc1.name}-subnet-${random_id.name1.hex}-pgw"
    vpc = ibm_is_vpc.vpc1.id
    zone = local.ZONE1
}

resource "ibm_is_public_gateway" "subnet2_gateway" {
    name = "${ibm_is_vpc.vpc1.name}-subnet-${random_id.name2.hex}-pgw"
    vpc = ibm_is_vpc.vpc1.id
    zone = local.ZONE2
}

resource "ibm_is_subnet" "subnet1" {
  name                     = "${ibm_is_vpc.vpc1.name}-subnet-${random_id.name1.hex}"
  vpc                      = ibm_is_vpc.vpc1.id
  zone                     = local.ZONE1
  public_gateway           = ibm_is_public_gateway.subnet1_gateway.id
  ipv4_cidr_block          = "${var.zone1_prefix}/24"
}

resource "ibm_is_subnet" "subnet2" {
  name                     = "${ibm_is_vpc.vpc1.name}-subnet-${random_id.name2.hex}"
  vpc                      = ibm_is_vpc.vpc1.id
  zone                     = local.ZONE2
  public_gateway           = ibm_is_public_gateway.subnet2_gateway.id
  ipv4_cidr_block          = "${var.zone2_prefix}/24"
}

data "ibm_resource_group" "resource_group" {
  name = var.resource_group
}

resource "ibm_container_vpc_cluster" "cluster" {
  name              = random_pet.cluster_name.id
  vpc_id            = ibm_is_vpc.vpc1.id
  kube_version      = var.kube_version
  flavor            = var.flavor
  worker_count      = var.worker_count
  resource_group_id = data.ibm_resource_group.resource_group.id

  zones {
    subnet_id = ibm_is_subnet.subnet1.id
    name      = local.ZONE1
  }
}



