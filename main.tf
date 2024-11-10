provider "aws" {
    region ="eu-north-1"
  
}

module "vpc" {
    source = "./vpc"
    vpc_cidr_block = var.vpc_cidr_block
    tags = local.project_tags
    frontend_cidr_block = var.frontend_cidr_block
    availability_zone = var.availability_zone
    backend_cidr_block = var.backend_cidr_block

}

module "alb" {
    source = "./alb"
    frontend_subnet_az1a_id = module.vpc.frontend_subnet_az1a_id
    frontend_subnet_az1b_id = module.vpc.frontend_subnet_az1b_id
    tags = local.project_tags
    ssl_policy = var.ssl_policy
    vpc_id = module.vpc.vpc_id
    certificate_arn = var.certificate_arn
   
  
}

module "auto-scaling" {
  source = "./auto-scaling"
  instance_type = var.instance_type
  key_name = var.key_name
  frontend_subnet_az1a_id = module.vpc.frontend_subnet_az1a_id
  frontend_subnet_az1b_id = module.vpc.frontend_subnet_az1b_id
  alb_sg = module.alb.alb_sg
  target_group_arn = module.alb.target_group_arn
  image_id = var.image_id
  vpc_id = module.vpc.vpc_id
}

module "route53" {
  source = "./route53"
  alb_dns_name = module.alb.alb_dns_name
  dns_name = var.dns_name
  zone_id = var.zone_id
  alb_zone_id = module.alb.alb_zone_id
}