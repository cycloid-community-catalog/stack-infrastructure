output "iam_policy_infra-backup" {
  value = "${module.infrastructure.iam_policy_backup}"
}

output "iam_policy_infra-logs" {
  value = "${module.infrastructure.iam_policy_infra-logs}"
}

output "deployment_bucket_name" {
  value = "${module.infrastructure.deployment_bucket_name}"
}

output "iam_policy_s3-deployment" {
  value = "${module.infrastructure.iam_policy_s3-deployment}"
}

output "zones" {
  value = "${module.infrastructure.zones}"
}
