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
  source            = "../../modules/networking/nat"
  public_subnet_id  = module.subnet.public_subnet_ids[0]
}

module "route" {
  source             = "../../modules/networking/route"
  vpc_id             = module.vpc.vpc_id
  igw_id             = module.igw.igw_id
  public_subnet_ids  = module.subnet.public_subnet_ids
  nat_gateway_id     = module.nat.nat_gateway_id
}

module "eks_roles" {
  source = "../../modules/iam"
}

module "eks" {
  source         = "../../modules/eks"
  cluster_name   = "news-cluster"
  subnet_ids     = module.subnet.private_subnet_ids
  eks_role_arn   = module.eks_roles.eks_cluster_role_arn
  node_role_arn  = module.eks_roles.eks_node_role_arn
}
