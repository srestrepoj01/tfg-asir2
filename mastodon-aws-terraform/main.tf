module "vpc" {
  source        = "./modules/vpc"
  project_name  = var.project_name
}

module "security" {
  source        = "./modules/security"
  vpc_id        = module.vpc.vpc_id
  project_name  = var.project_name
}

module "iam" {
  source        = "./modules/iam"
  project_name  = var.project_name
}

module "ec2" {
  source               = "./modules/ec2"
  vpc_id               = module.vpc.vpc_id
  public_subnet_ids    = module.vpc.public_subnet_ids
  sg_id                = module.security.ec2_sg_id
  iam_instance_profile = module.iam.instance_profile_name
  instance_type        = var.instance_type
  instance_count       = var.instance_count
  ssh_key_name         = var.ssh_key_name
  project_name         = var.project_name
  private_key_path     = var.private_key_path
}

module "rds" {
  source             = "./modules/rds"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  sg_id              = module.security.rds_sg_id
  project_name       = var.project_name
  db_username        = var.db_username
  db_password        = var.db_password
}

module "alb" {
  source             = "./modules/alb"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  sg_id              = module.security.alb_sg_id
  project_name       = var.project_name
  ec2_instance_ids   = module.ec2.instance_ids
}

module "cloudwatch" {
  source                          = "./modules/cloudwatch"
  project_name                    = var.project_name
  ec2_instance_ids                = module.ec2.instance_ids
  rds_instance_id                 = module.rds.db_instance_id
  lb_arn_suffix                   = module.alb.lb_arn_suffix
  target_group_web_arn_suffix     = module.alb.target_group_web_arn_suffix
  target_group_streaming_arn_suffix = module.alb.target_group_streaming_arn_suffix
  alarm_email                     = var.alarm_email
}