# provider.tf
variable "region" {
  type = string
  default = "ap-south-1"
}

variable "profile" {
  type = string
  description = "used to refernce specific aws account (as i have 2)"
}

# network.tf 
variable "vpc_cidr_block" {
  type = string
  description = "This is cidr block of our vpc"
}

variable "availability_zones" {
  type = list(string)
  description = "Includes az's in which i will be deploying our resources"
}

# compute.tf
variable "" {
  
}

variable "" {
  
}

variable "" {
  
}

variable "" {
  
}

variable "" {
  
}

variable "" {
  
}

variable "" {
  
}