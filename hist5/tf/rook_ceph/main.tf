module "common" {
  source = "./common"
}

module "crds" {
  source = "./crds"
}

module "operator" {
  source = "./operator"
  namespace = module.common.namespace
}

module "site" {
  source = "./site"
  namespace = module.common.namespace
}

module "toolbox" {
  source = "./toolbox"
  namespace = module.common.namespace
}

output "storage_classes" {
  value = module.site.storage_classes
}
