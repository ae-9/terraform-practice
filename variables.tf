variable "aws_access_key" {
  type    = string
  default = "<>"

}

variable "aws_secret_key" {
  type    = string
  default = "<>"

}

# variable "aws_region" {
#   type        = string
#   description = "aws region to use"
# }

variable "zones" {
  default = ["us-east-1b", "us-east-1c", "us-east-1d"]
}

variable "app_name" {
  type        = string
  description = "Application name"
}

# variable "app_environment" {
#   type        = string
#   description = "Application environment"
# }

variable "ec2_use_case" {
  default = "ec2_demo"
}

variable "ec2_name" {
  default = "ec2_RHEL_vm"
}

variable "ec2_instance_type" {
  default = "t2.micro"
}

variable "ec2_public_ip_association" {
  description = "associate the public ip to the ec2"
  type        = bool
  default     = true
}

variable "ec2_root_volume_size" {
  description = "volume size of the root volume"
  type        = number
}

variable "ec2_root_volume_type" {
  description = "volume type of the root volume"
  type        = string
  default     = "gp2"
}

# variable "ec2_data_volume_size" {
#     description = "volume size of the data volume"
#     type = number
# }

# variable "ec2_data_volume_type" {
#     description = "volume type of the data volume"
#     type = string
#     default = "gp2"
# }

variable "ec2_az" {
  type        = string
  description = "AWS AZ"
  default     = "us-east-1a"
}

variable "ec2_vpc_cidr" {
  type        = string
  description = "CIDR for the VPC"
  default     = "10.1.64.0/18"
}

variable "ec2_public_subnet_cidr" {
  type        = string
  description = "CIDR for the public subnet"
  default     = "10.1.64.0/24"
}