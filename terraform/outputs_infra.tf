output "bastion_ip" {
  value = ["${module.infrastructure.bastion_ip}"]
}

output "infra_vpc_id" {
  value = "${module.infrastructure.infra_vpc_id}"
}

output "infra_private_subnets" {
  value = ["${module.infrastructure.infra_private_subnets}"]
}

output "infra_public_subnets" {
  value = ["${module.infrastructure.infra_public_subnets}"]
}

output "infra_bastion_sg_allow" {
  value = "${module.infrastructure.infra_bastion_sg_allow}"
}

output "infra_private_zone_id" {
  value = "${module.infrastructure.infra_private_zone_id}"
}

output "infra_rds_parameters-mysql57" {
  value = "${module.infrastructure.infra_rds_parameters-mysql57}"
}

output "iam_ses_smtp_user_key" {
  value = "${module.infrastructure.iam_ses_smtp_user_key}"
}

output "iam_ses_smtp_user_secret" {
  value = "${module.infrastructure.iam_ses_smtp_user_secret}"
}
