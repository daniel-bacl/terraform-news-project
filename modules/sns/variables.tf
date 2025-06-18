variable "topic_name" {
  description = "SNS topic name"
  type        = string
}

variable "display_name" {
  description = "Optional display name for the SNS topic"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the SNS topic"
  type        = map(string)
  default     = {}
}

variable "subscriptions" {
  description = "List of SNS subscriptions to create, each with protocol and endpoint"
  type = list(object({
    protocol      = string
    endpoint      = string
    filter_policy = optional(string)
  }))
  default = []
}