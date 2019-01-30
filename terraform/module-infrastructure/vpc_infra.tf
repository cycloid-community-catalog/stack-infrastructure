#
# Variables
#
variable "infra_cidr" {
  description = "The CIDR of the infra VPC"
  default     = "10.0.0.0/16"
}

variable "infra_private_subnets" {
  description = "The private subnets for the infra VPC"
  default     = ["10.0.0.0/24", "10.0.2.0/24", "10.0.4.0/24"]
}

variable "infra_public_subnets" {
  description = "The private subnets for the infra VPC"
  default     = ["10.0.1.0/24", "10.0.3.0/24", "10.0.5.0/24"]
}

variable "bastion_count" {
  description = "Number of bastions to create (use 0 if you want no bastion)"
  default     = 1
}

variable "bastion_allowed_networks" {
  description = "Networks allowed to connect to the bastion using SSH"
  default     = "0.0.0.0/0"
}

variable "bastion_instance_type" {
  description = "Instance type for the bastion"
  default     = "t2.micro"
}

#
# Create VPC
#

module "infra_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.customer}-infra${var.suffix}"
  azs  = "${var.zones}"
  cidr = "${var.infra_cidr}"

  private_subnets    = "${var.infra_private_subnets}"
  enable_nat_gateway = true
  single_nat_gateway = true
  public_subnets     = "${var.infra_public_subnets}"

  enable_dns_hostnames     = true
  enable_dhcp_options      = true
  dhcp_options_domain_name = "${var.customer}.infra"

  tags = {
    client     = "${var.customer}"
    project    = "${var.project}"
    env        = "${var.env}"
    cycloid.io = "true"
  }
}

resource "aws_security_group" "allow_bastion_infra" {
  count = "${var.bastion_count > 0 ? 1 : 0 }"

  name        = "allow-bastion-infra${var.suffix}"
  description = "Allow SSH traffic from the bastion to the infra"
  vpc_id      = "${module.infra_vpc.vpc_id}"

  ingress = {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
    self            = false
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name       = "allow-bastion-infra${var.suffix}"
    client     = "${var.customer}"
    project    = "${var.project}"
    env        = "${var.env}"
    cycloid.io = "true"
  }
}

# Create route53 zones
## Private zone
resource "aws_route53_zone" "infra_private" {
  name   = "${var.customer}.infra"
  vpc_id = "${module.infra_vpc.vpc_id}"

  tags {
    client     = "${var.customer}"
    project    = "${var.project}"
    env        = "${var.env}"
    cycloid.io = "true"
  }
}

// Expose the private zone id
output "infra_private_zone_id" {
  value = "${aws_route53_zone.infra_private.zone_id}"
}

output "infra_bastion_sg_allow" {
  value = "${element(aws_security_group.allow_bastion_infra.*.id, 0)}"
}

#
# mysql
#

resource "aws_db_parameter_group" "infra_rds-optimized-mysql57" {
  name        = "rds-optimized-mysql-${var.customer}-infra"
  family      = "mysql5.7"
  description = "Cycloid optimizations for ${var.customer}-infra"

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

// Expose the mysql rds parameters
output "infra_rds_parameters-mysql57" {
  value = "${aws_db_parameter_group.infra_rds-optimized-mysql57.id}"
}

output "infra_vpc_id" {
  value = "${module.infra_vpc.vpc_id}"
}

output "infra_private_subnets" {
  value = ["${module.infra_vpc.private_subnets}"]
}

output "infra_public_subnets" {
  value = ["${module.infra_vpc.public_subnets}"]
}
