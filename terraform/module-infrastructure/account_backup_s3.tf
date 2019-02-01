locals {
  backup_bucket_prefix = "${var.backup_bucket_prefix == "" ? "${var.customer}-" : var.backup_bucket_prefix}"
}

data "aws_iam_policy_document" "s3_backup" {
  statement {
    effect  = "Allow"
    actions = ["*"]

    resources = [
      "arn:aws:s3:::${local.backup_bucket_prefix}backup/*",
      "arn:aws:s3:::${local.backup_bucket_prefix}backup",
    ]
  }
}

resource "aws_iam_policy" "s3_backup" {
  name   = "s3-backup${var.suffix}"
  path   = "/cycloid/"
  policy = "${data.aws_iam_policy_document.s3_backup.json}"
}

resource "aws_iam_role_policy_attachment" "infra_backup" {
  role       = "${aws_iam_role.infra.name}"
  policy_arn = "${aws_iam_policy.s3_backup.arn}"
}

resource "aws_s3_bucket" "backup" {
  bucket = "${local.backup_bucket_prefix}backup"
  acl    = "private"

  lifecycle {
    ignore_changes = [
      "lifecycle_rule",
    ]
  }

  tags {
    Name       = "${local.backup_bucket_prefix}backup"
    client     = "${var.customer}"
    customer   = "${var.customer}"
    project    = "${var.project}"
    env        = "${var.env}"
    cycloid.io = "true"
  }
}

// Expose iam policy for backups
output "iam_policy_backup" {
  value = "${aws_iam_policy.s3_backup.arn}"
}