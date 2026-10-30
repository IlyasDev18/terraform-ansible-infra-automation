variable "node_count" {
  description = "Number of target Linux container nodes to provision"
  type        = number
  default     = 2
}

variable "base_ssh_port" {
  description = "Starting host port for mapping SSH into target containers"
  type        = number
  default     = 2221
}