output "dev_bastion_sg_allow" {
  description = "security group ID tp allow SSH traffic from the bastion to the dev instances"
  value       = module.infrastructure.dev_bastion_sg_allow
}

output "dev_vpc_id" {
  description = "The VPC ID for the dev VPC"
  value       = module.infrastructure.dev_vpc_id
}

output "dev_vpc_cidr" {
  description = "The CIDR for the dev VPC"
  value       = module.infrastructure.dev_vpc_cidr
}

output "dev_public_route_table_ids" {
  description = "The public route table IDs for the dev VPC"
  value       = module.infrastructure.dev_public_route_table_ids
}

output "dev_private_route_table_ids" {
  description = "The private route table IDs for the dev VPC"
  value       = module.infrastructure.dev_private_route_table_ids
}

output "dev_private_subnets" {
  description = "The private subnets for the dev VPC"
  value       = module.infrastructure.dev_private_subnets
}

output "dev_public_subnets" {
  description = "The public subnets for the dev VPC"
  value       = module.infrastructure.dev_public_subnets
}

output "dev_elasticache_subnets" {
  description = "The elasticache subnets for the dev VPC"
  value       = module.infrastructure.dev_elasticache_subnets
}

output "dev_elasticache_subnet_group" {
  description = "The elasticache subnet group for the dev VPC"
  value       = module.infrastructure.dev_elasticache_subnet_group
}

output "dev_rds_subnets" {
  description = "The RDS subnets for the dev VPC"
  value       = module.infrastructure.dev_rds_subnets
}

output "dev_rds_subnet_group" {
  description = "The RDS subnet group for the dev VPC"
  value       = module.infrastructure.dev_rds_subnet_group
}

output "dev_redshift_subnets" {
  description = "The redshift subnets for the dev VPC"
  value       = module.infrastructure.dev_redshift_subnets
}

output "dev_redshift_subnet_group" {
  description = "The Redshift subnet group for the dev VPC"
  value       = module.infrastructure.dev_redshift_subnet_group
}

output "dev_private_zone_id" {
  description = "Route53 private zone ID for the dev VPC"
  value       = module.infrastructure.dev_private_zone_id
}

output "dev_rds_parameters-mysql57" {
  description = "RDS db parameters ID for the dev VPC"
  value       = module.infrastructure.dev_rds_parameters-mysql57
}

