terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "ecr" {
  source       = "./modules/ecr"
  name         = var.app_name
  scan_on_push = true
}

module "network" {
  source             = "./modules/network"
  name               = var.app_name
  cidr_block         = var.vpc_cidr
  az_count           = 2
  public_cidrs       = var.public_subnet_cidrs
  private_cidrs      = var.private_subnet_cidrs
  create_nat_gateway = true
}

module "alb" {
  source                 = "./modules/alb"
  name                   = var.app_name
  vpc_id                 = module.network.vpc_id
  public_subnet_ids      = module.network.public_subnet_ids
  health_check_path      = "/health"
  listener_port_http     = 80
  enable_https       = false
}

module "ecs" {
  source               = "./modules/ecs"
  name                 = var.app_name
  cluster_name         = "${var.app_name}-cluster"
  vpc_id               = module.network.vpc_id
  private_subnet_ids   = module.network.private_subnet_ids
  container_image      = "${module.ecr.repository_url}:${var.image_tag}"
  container_port       = 3000
  desired_count        = 2
  cpu                  = 256
  memory               = 512
  alb_target_group_arn = module.alb.target_group_arn
  alb_sg_id            = module.alb.sg_id
  secrets = [
    # Example: uncomment and set ARN
    # {
    #   name      = "DUMMY_API_KEY"
    #   valueFrom = var.secrets_manager_arn
    # }
  ]
}
