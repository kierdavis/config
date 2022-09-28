module "upstream" {
  source = "./upstream"
}

module "site" {
  source = "./site"
  #depends_on = [module.upstream]
}

output "storage_classes" {
  value = module.site.storage_classes
}
