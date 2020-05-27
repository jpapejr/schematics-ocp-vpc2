variable "flavor" {
  default = "bx2.2x8"
}

variable "kube_version" {
  default = "1.17.5"
}

variable "worker_count" {
  default = "1"
}

variable "region" {
  default = "us-south"
}

variable "resource_group" {
  default = "default"
}

variable "worker_pool_name" {
  default = "workerpool"
}
