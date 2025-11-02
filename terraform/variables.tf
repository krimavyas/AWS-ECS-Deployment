variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "hello-ecs"
}

variable "image_tag" {
  description = "Docker image tag for ECS deployment"
  type        = string
  default     = "v1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS (optional)"
  type        = string
  default     = null
}

variable "secrets_manager_arn" {
  description = "ARN of AWS Secrets Manager secret (optional)"
  type        = string
  default     = null
}
