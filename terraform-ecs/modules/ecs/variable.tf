variable "name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}

variable "alb_target_group_arn" {
  type = string
}

variable "container_image" {
  type = string
}

variable "container_port" {
  type    = number
  default = 3000
}

variable "desired_count" {
  type    = number
  default = 2
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "secrets" {
  description = "List of objects { name, valueFrom } referencing AWS Secrets Manager ARNs"
  type        = list(object({ name = string, valueFrom = string }))
  default     = []
}
