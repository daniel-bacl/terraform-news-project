# ─────────────────────────────
# 네트워킹
# ─────────────────────────────

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
  source = "../../modules/networking/security_group"
  vpc_id = module.vpc.vpc_id
}

# ─────────────────────────────
# IAM 및 클러스터
# ─────────────────────────────

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

# ─────────────────────────────
# 데이터베이스
# ─────────────────────────────

module "rds" {
  source             = "../../modules/rds"
  name               = "news-rds"
  subnet_ids         = module.subnet.private_subnet_ids
  instance_class     = "db.t3.micro"
  allocated_storage  = 20
  username           = var.lambda_env["DB_USER"]
  password           = var.lambda_env["DB_PASSWORD"]
  db_name            = var.lambda_env["DB_NAME"]
  security_group_ids = [module.security_group.rds_sg_id]

  depends_on = [
    module.subnet,
    module.security_group
  ]
}

# ─────────────────────────────
# Lambda & Layer
# ─────────────────────────────

module "lambda_layer" {
  source     = "../../modules/lambda/layer"
}

module "sending_news" {
  source            = "../../modules/lambda/sending_news"
  function_name     = "news-lambda-handler"
  lambda_role_arn   = module.iam.lambda_role_arn
  handler           = "lambda_function.lambda_handler"
  runtime           = "python3.11"
  filename          = "${path.module}/../../zip/lambda_function.zip"
  pymysql_layer_arn = module.lambda_layer.pymysql_layer_arn
  subnet_ids        = module.subnet.private_subnet_ids
  security_group_id = module.security_group.app_sg_id
  ses_sender        = var.lambda_env["SES_SENDER"]

  environment = merge(
    var.lambda_env,
    {
      DB_HOST = module.rds.rds_endpoint
    }
  )

  depends_on = [
    module.rds,
    module.lambda_layer
  ]
}

module "sql_initializer" {
  source                   = "../../modules/lambda/sql_initializer"
  lambda_role_arn          = module.iam.lambda_role_arn
  db_host                  = module.rds.rds_endpoint
  db_user                  = var.lambda_env["DB_USER"]
  db_password              = var.lambda_env["DB_PASSWORD"]
  db_name                  = var.lambda_env["DB_NAME"]
  private_subnet_ids       = module.subnet.private_subnet_ids
  lambda_security_group_id = module.security_group.app_sg_id
  pymysql_layer_arn        = module.lambda_layer.pymysql_layer_arn

  depends_on = [
    module.rds,
    module.lambda_layer
  ]
}