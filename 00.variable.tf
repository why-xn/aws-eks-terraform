variable "aws_region" {
  default = "ap-southeast-1"
  type    = string
}

variable "cluster_name" {
  default = "whyxn-eks"
  type    = string
}

variable "k8s_version" {
  default = "1.22"
  type    = string
}

variable "cluster_endpoint_is_private" {
  default = false
  type    = bool
}

variable "cluster_endpoint_is_public" {
  default = true
  type    = bool
}

variable "node_capacity_type" {
  default = "ON_DEMAND"
  type    = string
}

variable "node_instance_type" {
  default = "t2.medium"
  type    = string
}

variable "node_desired_size" {
  default = 1
  type    = number
}

variable "node_max_size" {
  default = 2
  type    = number
}

variable "node_min_size" {
  default = 0
  type    = number
}

variable "node_label_key" {
  default = "role"
  type    = string
}

variable "node_label_value" {
  default = "common"
  type    = string
}