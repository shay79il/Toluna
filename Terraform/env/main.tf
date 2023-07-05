module "iam" {
  source = "../modules/iam"

  effect                = var.effect
  actions               = var.actions
  principal_type        = var.principal_type
  principal_identifiers = var.principal_identifiers
  role_name             = var.role_name
  policy_arn            = var.policy_arn
}

module "vpc" {
  source = "../modules/vpc"

  env                  = var.env
  region               = var.region
  vpc_cidr_block       = var.vpc_cidr_block
  subnets              = var.subnets
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

}

module "sg" {
  source = "../modules/sg"

  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = var.vpc_cidr_block
  alb_sg_ingress = var.alb_sg_ingress
  alb_sg_egress  = var.alb_sg_egress
  ecs_sg_ingress = var.ecs_sg_ingress
  ecs_sg_egress  = var.ecs_sg_egress
  depends_on     = [module.vpc]
}

module "alb" {
  source = "../modules/alb"

  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.public_subnets_ids
  alb_sg_ids                 = [module.sg.sg_id_alb]
  tg_ecs_fargate_port        = var.tg_ecs_fargate_port
  tg_ecs_fargate_protocol    = var.tg_ecs_fargate_protocol
  tg_ecs_tg_type             = var.tg_ecs_tg_type
  ecs_listeners              = var.ecs_listeners
  enable_deletion_protection = var.enable_deletion_protection

  depends_on = [module.sg]
}

module "ecr" {
  source = "../modules/ecr"

  env                 = var.env
  region              = var.region
  vpc_id              = module.vpc.vpc_id
  vpc_endpoint_type   = var.vpc_endpoint_type
  private_dns_enabled = var.private_dns_enabled
  private_subnet_ids  = module.vpc.private_subnet_ids
  private_rt_id       = module.vpc.private_rt_id
  security_group_ids  = [module.sg.sg_id_ecs]

  depends_on = [module.sg]
}

module "ecs" {
  source = "../modules/ecs"

  env                = var.env
  region             = var.region
  aws_account_id     = data.aws_caller_identity.current.account_id
  execution_role_arn = module.iam.aws_iam_role_arn

  image_name     = var.image_name
  container_port = var.ecs_container_port
  cpu            = var.ecs_container_cpu
  memory         = var.ecs_container_memory

  # aws_ecs_service
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_ids = [module.sg.sg_id_ecs]
  tg_ecs_fargate_arn = module.alb.tg_ecs_fargate_arn
  desired_count      = var.ecs_service_desired_count
  launch_type        = var.launch_type

  depends_on = [module.alb]

}

module "sns" {
  source   = "../modules/sns"
  topics   = var.topics
  protocol = var.protocol
  endpoint = var.endpoint

  depends_on = [module.ecs]
}



module "alarm" {
  source = "../modules/alarm"

  alarm_name          = var.alarm_name
  comparison_operator = var.comparison_operator
  evaluation_periods  = var.evaluation_periods
  metric_name         = var.metric_name
  namespace           = var.namespace
  period              = var.period
  statistic           = var.statistic
  threshold           = var.threshold
  alarm_description   = var.alarm_description

  alarm_actions       = module.sns.sns_topics_arns

  dimension           = module.alb.tg_ecs_fargate_arn_suffix

  depends_on = [module.sns]
}



