provider "ibm" {
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
}

resource "ibm_is_vpc" "vpc1" {
  name = "vpc-${random_id.name1.hex}"
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
  total_ipv4_address_count = 256
}

resource "ibm_is_subnet" "subnet2" {
  name                     = "${ibm_is_vpc.vpc1.name}-subnet-${random_id.name2.hex}"
  vpc                      = ibm_is_vpc.vpc1.id
  zone                     = local.ZONE2
  public_gateway           = ibm_is_public_gateway.subnet2_gateway.id
  total_ipv4_address_count = 256
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

resource "ibm_container_vpc_worker_pool" "cluster_pool" {
  cluster           = ibm_container_vpc_cluster.cluster.id
  worker_pool_name  = "${var.worker_pool_name}-${random_id.name1.hex}"
  flavor            = var.flavor
  vpc_id            = ibm_is_vpc.vpc1.id
  worker_count      = var.worker_count
  resource_group_id = data.ibm_resource_group.resource_group.id
  zones {
    name      = local.ZONE2
    subnet_id = ibm_is_subnet.subnet2.id
  }
}


