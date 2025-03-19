variable "cluster_name" {
  type        = string
  description = "The cluster name"
}

variable "region" {
  type        = string
  description = "The region in which the cluster is defined"
}

variable "aws_lb_controller_version"{
  type = string
  description = "The version of Load Balancer Controller to be used"
}
