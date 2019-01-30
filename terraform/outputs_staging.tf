output "staging_bastion_sg_allow" {
  value = "${module.infrastructure.staging_bastion_sg_allow}"
}

output "staging_vpc_id" {
  value = "${module.infrastructure.staging_vpc_id}"
}

output "staging_private_subnets" {
  value = ["${module.infrastructure.staging_private_subnets}"]
}

output "staging_public_subnets" {
  value = ["${module.infrastructure.staging_public_subnets}"]
}

output "staging_elasticache_subnets" {
  value = ["${module.infrastructure.staging_elasticache_subnets}"]
}

output "staging_elasticache_subnet_group" {
  value = "${module.infrastructure.staging_elasticache_subnet_group}"
}

output "staging_rds_subnets" {
  value = ["${module.infrastructure.staging_rds_subnets}"]
}

output "staging_rds_subnet_group" {
  value = "${module.infrastructure.staging_rds_subnet_group}"
}

output "staging_redshift_subnets" {
  value = ["${module.infrastructure.staging_redshift_subnets}"]
}

output "staging_redshift_subnet_group" {
  value = "${module.infrastructure.staging_redshift_subnet_group}"
}

output "staging_private_zone_id" {
  value = "${module.infrastructure.staging_private_zone_id}"
}

output "staging_rds_parameters-mysql57" {
  value = "${module.infrastructure.staging_rds_parameters-mysql57}"
}
