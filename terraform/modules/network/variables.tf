variable "name" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "public_cidrs" {
  type = list(string)
}

variable "private_cidrs" {
  type = list(string)
}

variable "az_count" {
  type    = number
  default = 2
}

variable "create_nat_gateway" {
  type    = bool
  default = true
}
