output "prod_bastion_sg_allow" {
  value = "${module.infrastructure.prod_bastion_sg_allow}"
}

output "prod_vpc_id" {
  value = "${module.infrastructure.prod_vpc_id}"
}

output "prod_private_subnets" {
  value = ["${module.infrastructure.prod_private_subnets}"]
}

output "prod_public_subnets" {
  value = ["${module.infrastructure.prod_public_subnets}"]
}

output "prod_elasticache_subnets" {
  value = ["${module.infrastructure.prod_elasticache_subnets}"]
}

output "prod_elasticache_subnet_group" {
  value = "${module.infrastructure.prod_elasticache_subnet_group}"
}

output "prod_rds_subnets" {
  value = ["${module.infrastructure.prod_rds_subnets}"]
}

output "prod_rds_subnet_group" {
  value = "${module.infrastructure.prod_rds_subnet_group}"
}

output "prod_redshift_subnets" {
  value = ["${module.infrastructure.prod_redshift_subnets}"]
}

output "prod_redshift_subnet_group" {
  value = "${module.infrastructure.prod_redshift_subnet_group}"
}

output "prod_private_zone_id" {
  value = "${module.infrastructure.prod_private_zone_id}"
}

output "prod_rds_parameters-mysql57" {
  value = "${module.infrastructure.prod_rds_parameters-mysql57}"
}
