module "vpc" {
  source = "../../modules/networking/vpc"
}

module "subnet" {
  source = "../../modules/networking/subnet"
  vpc_id = module.vpc.vpc_id
}

module "igw" {
  source = "../../modules/networking/igw"
  vpc_id = module.vpc.vpc_id
}

module "nat" {
  source           = "../../modules/networking/nat"
  public_subnet_id = module.subnet.public_subnet_ids[0]
}

module "route" {
  source             = "../../modules/networking/route"
  vpc_id             = module.vpc.vpc_id
  igw_id             = module.igw.igw_id
  public_subnet_ids  = module.subnet.public_subnet_ids
  private_subnet_ids = module.subnet.private_subnet_ids
  nat_gateway_id     = module.nat.nat_gateway_id
}

module "security_group" {
  source       = "../../modules/networking/security_group"
  vpc_id       = module.vpc.vpc_id
}

module "iam" {
  source = "../../modules/iam"
}

module "eks" {
  source        = "../../modules/eks"
  cluster_name  = "news-cluster"
  subnet_ids    = module.subnet.private_subnet_ids
  eks_role_arn  = module.iam.eks_cluster_role_arn
  node_role_arn = module.iam.eks_node_role_arn

  depends_on = [
    module.subnet,
    module.iam
  ]
}

module "rds" {
  source             = "../../modules/rds"
  name               = "news-rds"
  subnet_ids         = module.subnet.private_subnet_ids
  instance_class     = "db.t3.micro"
  allocated_storage  = 20
  username           = "root"
  password           = var.db_password
  db_name            = "NewsSubscribe"
  security_group_ids = [module.security_group.rds_sg_id]

  depends_on = [
    module.security_group
  ]
}

module "lambda_layer" {
  source = "../../modules/lambda/layer"
}

module "sql_initializer" {
  source                   = "../../modules/lambda/sql_initializer"
  lambda_role_arn          = module.iam.lambda_role_arn
  db_host                  = module.rds.rds_endpoint
  db_user                  = "root"
  db_password              = var.db_password
  db_name                  = "NewsSubscribe"
  private_subnet_ids       = module.subnet.private_subnet_ids
  lambda_security_group_id = module.security_group.app_sg_id
  pymysql_layer_arn        = module.lambda_layer.pymysql_layer_arn

  depends_on = [
    module.rds,
    module.lambda_layer
  ]
}



