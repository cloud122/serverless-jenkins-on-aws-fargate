data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
locals {
  account_id  = data.aws_caller_identity.current.account_id
  region      = data.aws_region.current.name
  name_prefix = "serverless-jenkins"

  tags = {
    team     = "devops"
    solution = "jenkins"
  }
}

module myip {
  source  = "4ops/myip/http"
  version = "1.0.0"
}

// Bring your own ACM cert for the Application Load Balancer
# module "acm" {
#   source  = "terraform-aws-modules/acm/aws"
#   version = "~> v2.0"

#   domain_name = "${var.jenkins_dns_alias}.${var.route53_domain_name}"
#   zone_id     = var.route53_zone_id

#   tags = local.tags
# }

// An example of creating a KMS key
resource "aws_kms_key" "efs_kms_key" {
  description = "KMS key used to encrypt Jenkins EFS volume"
}


module "serverless_jenkins" {
  source                          = "./modules/jenkins_platform"
  name_prefix                     = local.name_prefix
  tags                            = local.tags
  vpc_id                          = module.jenkins_network.vpc_id
  #efs_kms_key_arn                 = module.jenkins_network.jenkins_cert_arn
  efs_subnet_ids                  = module.jenkins_network.private_subnet_list 
  jenkins_controller_subnet_ids   = module.jenkins_network.private_subnet_list 
  alb_subnet_ids                  = module.jenkins_network.pub_subnet_list
  alb_ingress_allow_cidrs         = ["${module.myip.address}/32"]
  #alb_acm_certificate_arn         = module.acm.this_acm_certificate_arn
  alb_acm_certificate_arn         = module.jenkins_network.jenkins_cert_arn
  #route53_create_alias            = true
  #route53_alias_name              = var.jenkins_dns_alias
  #route53_zone_id                 = var.route53_zone_id
  #route53_zone_id                 = aws_route53_zone.primary.zone_id

}

module "jenkins_network" {
  source                          = "./modules/network"
}

