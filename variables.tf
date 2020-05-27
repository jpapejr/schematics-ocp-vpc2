variable "flavor" {
  default = "bx2.4x16"
}

variable "vpc" {}
variable "subnet1" {}
variable "subnet2" {}
variable "subnet3" {}

variable "kube_version" {
  default = "4.3.19_openshift"
}

variable "worker_count" {
  default = "1"
}

variable "region" {
  default = "us-south"
}

variable "resource_group" {
  default = "Default"
}

variable "cluster_name" {
  default = "cluster"
}

variable "worker_pool_name" {
  default = "default"
}