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
variable "instance_type" {
  type = string
  description = "EC2 instance size used by web,app and db tier"
  default = "t2.micro"
}

variable "ami_bastion" {
  type = string
  description = "ami id for bastion host ec2 instance"
}

variable "ami_web" {
  type = string
  description = "ami id for web tier instances - custom ami using packer"
}

variable "ami_app" {
  type = string
  description = "ami id for app tier instances - custom ami using packer"
}

variable "ami_db" {
  type = string
  description = "ami id for db tier instances - custom ami using packer"
}

variable "ami_ids_map" {
  type = map(string)
}


variable "" {
  
}

variable "" {
  
}

variable "" {
  
}