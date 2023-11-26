variable "ami" {
  default = "ami-0261755bbcb8c4a84"
}

variable "instance_name" {
  default = "app_server"
}

variable instance_type {
  description = "Instance Type to provision for EC2"
  default = "t2.nano"
}

variable "instance_tag" {
  default = "Terraform EC2 Test"
}

variable "key_name" {
  description = "SSH Key used for the servers."
}

variable "vpc_id" {
  description = "VPC ID information for the Web servers."
}

variable "subnet_id" {
  description = "Subnet ID information for the Web servers."
}

variable "subnet_id1" {
  description = "Subnet ID information for the Web servers."
}

variable "security_group" {
  description = "Subnet ID information for the Web servers."
}

variable "min_size" {
  description = "Minimum Desired Instance Count for Load Balancer."
  default = 2
}

variable "max_size" {
  description = "Maximum Desired Instance Count for Load Balancer."
  default = 5
}

variable "max_buffer_time" {
  description = "Buffer time to provision a new instance when using predictive scaling for Load Balancer."
  default = 10
}

variable "max_capacity_buffer" {
  description = "instance limit that can be provisioned using predictive scaling for Load Balancer."
  default = 10
}

variable "min_threshold" {
  description = "CPU Threshold percentage when reached can be used to trigger scaling for Load Balancer."
  default = 30
}

variable "max_threshold" {
  description = "CPU Threshold percentage when reached can be used to trigger scaling for Load Balancer."
  default = 70
}
