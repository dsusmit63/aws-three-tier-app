variable "aws_region" {
  description = "AWS region for the three-tier application"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "three-tier-app"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "availability_zones" {
  description = "Two Availability Zones for the deployment"
  type        = list(string)

  default = [
    "ap-south-1a",
    "ap-south-1b"
  ]

  validation {
    condition = (
      length(var.availability_zones) == 2 &&
      length(distinct(var.availability_zones)) == 2
    )

    error_message = "Provide exactly two unique Availability Zones."
  }
}

variable "vpc_cidr" {
  description = "IPv4 CIDR range for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "The VPC CIDR must be a valid IPv4 CIDR range."
  }
}
