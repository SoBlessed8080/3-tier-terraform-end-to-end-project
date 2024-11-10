variable "vpc_id" {
  type = string
}

variable "image_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "alb_sg" {
  type = string
}


variable "frontend_subnet_az1a_id" {
  type = string
  
}

variable "frontend_subnet_az1b_id" {
  type = string
  
}

variable "target_group_arn" {
    type = list(string)
  
}
