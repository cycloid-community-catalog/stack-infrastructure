#
# Variables
#
variable "dev_cidr" {
  description = "The CIDR of the dev VPC"
  default     = "10.3.0.0/16"
}

variable "dev_private_subnets" {
  description = "The private subnets for the dev VPC"
  default     = ["10.3.0.0/24", "10.3.2.0/24", "10.3.4.0/24"]
}

variable "dev_public_subnets" {
  description = "The public subnets for the dev VPC"
  default     = ["10.3.1.0/24", "10.3.3.0/24", "10.3.5.0/24"]
}

variable "dev_elasticache_subnets" {
  description = "The Elasticache subnets for the dev VPC"
  default     = []
}

variable "dev_rds_subnets" {
  description = "The RDS subnets for the dev VPC"
  default     = ["10.3.2.0/24", "10.3.6.0/24", "10.3.10.0/24"]
}

variable "dev_redshift_subnets" {
  description = "The Redshift subnets for the dev VPC"
  default     = []
}

# Fix for value of count cannot be computed, generating the count as the same way as amazon vpc module do : https://github.com/terraform-aws-modules/terraform-aws-vpc/blob/master/main.tf#L5
locals {
  dev_max_subnet_length = max(
    length(var.dev_private_subnets),
    length(var.dev_elasticache_subnets),
    length(var.dev_rds_subnets),
    length(var.dev_redshift_subnets),
  )
  dev_nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(local.aws_availability_zones) : local.dev_max_subnet_length
}

#
# Create VPC
#
module "dev_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> v2.17"

  name = "${var.customer}-dev${var.suffix}"
  azs  = local.aws_availability_zones
  cidr = var.dev_cidr

  private_subnets     = var.dev_private_subnets
  enable_nat_gateway  = true
  single_nat_gateway  = true
  public_subnets      = var.dev_public_subnets
  elasticache_subnets = var.dev_elasticache_subnets
  database_subnets    = var.dev_rds_subnets
  redshift_subnets    = var.dev_redshift_subnets

  enable_dns_hostnames     = true
  enable_dhcp_options      = true
  dhcp_options_domain_name = "${var.customer}.dev"

  enable_s3_endpoint       = var.enable_s3_endpoint
  enable_dynamodb_endpoint = var.enable_dynamodb_endpoint

  tags = local.merged_tags
}

resource "aws_vpc_peering_connection" "infra_dev" {
  peer_vpc_id = module.infra_vpc.vpc_id
  vpc_id      = module.dev_vpc.vpc_id
  auto_accept = true

  tags = merge(local.merged_tags, {
    Name       = "VPC Peering between infra and dev"
  })
}

resource "aws_route" "infra_dev_public" {
  #count = "${length(module.infra_vpc.public_route_table_ids)}"
  count = var.create_vpc && length(var.infra_public_subnets) > 0 ? 1 : 0

  route_table_id            = element(module.infra_vpc.public_route_table_ids, count.index)
  destination_cidr_block    = var.dev_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.infra_dev.id
}

resource "aws_route" "infra_dev_private" {
  #count = "${length(module.infra_vpc.private_route_table_ids)}"
  count = var.create_vpc && local.infra_max_subnet_length > 0 ? local.infra_nat_gateway_count : 0

  route_table_id            = element(module.infra_vpc.private_route_table_ids, count.index)
  destination_cidr_block    = var.dev_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.infra_dev.id
}

resource "aws_route" "dev_infra_public" {
  #count = "${length(module.infra_vpc.public_route_table_ids)}"
  count = var.create_vpc && length(var.dev_public_subnets) > 0 ? 1 : 0

  route_table_id            = element(module.dev_vpc.public_route_table_ids, count.index)
  destination_cidr_block    = var.infra_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.infra_dev.id
}

resource "aws_route" "dev_infra_private" {
  #count = "${length(module.infra_vpc.private_route_table_ids)}"
  count = var.create_vpc && local.dev_max_subnet_length > 0 ? local.dev_nat_gateway_count : 0

  route_table_id            = element(module.dev_vpc.private_route_table_ids, count.index)
  destination_cidr_block    = var.infra_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.infra_dev.id
}

resource "aws_security_group" "allow_bastion_dev" {
  count = var.bastion_count > 0 ? 1 : 0

  name        = "allow-bastion-dev${var.suffix}"
  description = "Allow SSH traffic from the bastion to the dev env"
  vpc_id      = module.dev_vpc.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion[0].id]
    self            = false
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.merged_tags, {
    Name       = "allow-bastion-dev${var.suffix}"
  })
}

# Create route53 zones
## Private zone
resource "aws_route53_zone" "dev_private" {
  name = "${var.customer}.dev"

  vpc {
    vpc_id = module.dev_vpc.vpc_id
  }

  tags = local.merged_tags

  lifecycle {
    ignore_changes = [vpc]
  }
}

resource "aws_route53_zone_association" "dev_private_infra" {
  zone_id = aws_route53_zone.dev_private.zone_id
  vpc_id  = module.infra_vpc.vpc_id
  count   = var.infra_associate_vpc_to_all_private_zones ? 1 : 0
}

#
# mysql
#

resource "aws_db_parameter_group" "dev_rds-optimized-mysql57" {
  name        = "rds-optimized-mysql-${var.customer}-dev"
  family      = "mysql5.7"
  description = "Cycloid optimizations for ${var.customer}-dev"

  parameter {
    name  = "log_bin_trust_function_creators"
    value = "1"
  }

  parameter {
    name         = "query_cache_type"
    value        = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "innodb_buffer_pool_size"
    value        = "{DBInstanceClassMemory*2/3}"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "max_allowed_packet"
    value        = "67108864"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "query_cache_size"
    value        = "67108864"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "tmp_table_size"
    value        = "134217728"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "max_heap_table_size"
    value        = "134217728"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "log_output"
    value = "file"
  }
}

#
# output
#

// Expose the mysql rds parameters
output "dev_rds_parameters-mysql57" {
  value = aws_db_parameter_group.dev_rds-optimized-mysql57.id
}

// Expose the private zone id
output "dev_private_zone_id" {
  value = aws_route53_zone.dev_private.zone_id
}

output "dev_bastion_sg_allow" {
  value = element(aws_security_group.allow_bastion_dev.*.id, 0)
}

output "dev_vpc_id" {
  value = module.dev_vpc.vpc_id
}

output "dev_vpc_cidr" {
  value = var.dev_cidr
}

output "dev_public_route_table_ids" {
  value = module.dev_vpc.public_route_table_ids
}

output "dev_private_route_table_ids" {
  value = module.dev_vpc.private_route_table_ids
}

output "dev_private_subnets" {
  value = module.dev_vpc.private_subnets
}

output "dev_public_subnets" {
  value = module.dev_vpc.public_subnets
}

output "dev_elasticache_subnets" {
  value = module.dev_vpc.elasticache_subnets
}

output "dev_elasticache_subnet_group" {
  value = module.dev_vpc.elasticache_subnet_group
}

output "dev_rds_subnets" {
  value = module.dev_vpc.database_subnets
}

output "dev_rds_subnet_group" {
  value = module.dev_vpc.database_subnet_group
}

output "dev_redshift_subnets" {
  value = module.dev_vpc.redshift_subnets
}

output "dev_redshift_subnet_group" {
  value = module.dev_vpc.redshift_subnet_group
}

