# Generic variables
variable "name" {
  description = "Name of the application"
  type        = string
  default     = "stable-diffusion"
}

variable "environment" {
  description = "Name of the environment"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnets" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnet IDs"
  type        = list(string)
}
