variable "name" {
  description = "Application name (used as a prefix for ALB resources)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ALB will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB deployment"
  type        = list(string)
}

variable "health_check_path" {
  description = "Path for ALB target group health check"
  type        = string
  default     = "/health"
}

variable "listener_port_http" {
  description = "Port number for HTTP listener"
  type        = number
  default     = 80
}

variable "enable_https" {
  description = "Whether to enable HTTPS listener"
  type        = bool
  default     = true
}

# Optional: Uncomment if you plan to use HTTPS (TLS)
variable "certificate_arn" {
  description = "ARN of ACM certificate for HTTPS listener"
  type        = string
  default     = null
}
