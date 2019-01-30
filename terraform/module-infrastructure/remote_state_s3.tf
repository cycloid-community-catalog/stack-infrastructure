# Create a bucket for terraform remote state
resource "aws_s3_bucket" "terraform_remote_state" {
  bucket = "${var.customer}-terraform-remote-state"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags {
    Name       = "terraform-remote-state"
    client     = "${var.customer}"
    project    = "${var.project}"
    env        = "${var.env}"
    cycloid.io = "true"
  }

  policy = <<EOF
{
  "Id": "PolicyAccessTerraformState",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllRights",
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.customer}-terraform-remote-state",
      "Principal": {
        "AWS": "${aws_iam_user.infra.arn}"
      }
    }
  ]
}
EOF
}
