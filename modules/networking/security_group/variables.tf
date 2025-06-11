variable "vpc_id" {
  type = string
}

variable "eks_node_sg_id" {
  description = "SG ID of EKS Node Group (cluster SG)"
  type        = string
}