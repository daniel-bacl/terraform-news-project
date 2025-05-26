module "vpc" {
  source = "../../modules/networking/vpc"
}

module "subnet" {
  source = "../../modules/networking/subnet"
}

module "route" {
  source = "../../modules/networking/route"
}

module "s3_backend" {
  source = "../../modules/bootstrap/s3-backend"
}
