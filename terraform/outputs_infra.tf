output "bastion_ip" {
  description = "EIP attached to the bastion EC2 server"
  value       = ["${module.infrastructure.bastion_ip}"]
}

output "infra_vpc_id" {
  description = "The VPC ID for the infra VPC"
  value       = "${module.infrastructure.infra_vpc_id}"
}

output "infra_private_subnets" {
  description = "The private subnets for the infra VPC"
  value       = ["${module.infrastructure.infra_private_subnets}"]
}

output "infra_public_subnets" {
  description = "The public subnets for the infra VPC"
  value       = ["${module.infrastructure.infra_public_subnets}"]
}

output "infra_bastion_sg_allow" {
  description = "security group ID tp allow SSH traffic from the bastion to the infra instances"
  value       = "${module.infrastructure.infra_bastion_sg_allow}"
}

output "infra_private_zone_id" {
  description = "Route53 private zone ID for the infra VPC"
  value       = "${module.infrastructure.infra_private_zone_id}"
}

output "infra_rds_parameters-mysql57" {
  description = "RDS parameter group ID for the infra VPC"
  value       = "${module.infrastructure.infra_rds_parameters-mysql57}"
}

output "iam_ses_smtp_user_key" {
  description = "Dedicated SES user"
  value       = "${module.infrastructure.iam_ses_smtp_user_key}"
}

output "iam_ses_smtp_user_secret" {
  description = "Dedicated SES user secret"
  value       = "${module.infrastructure.iam_ses_smtp_user_secret}"
}
