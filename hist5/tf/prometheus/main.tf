variable "storage_classes" {
  type = map(any)
}

module "upstream" {
  source = "./upstream"
}

module "site" {
  source = "./site"
  storage_classes = var.storage_classes
  #depends_on = [module.upstream]
}
