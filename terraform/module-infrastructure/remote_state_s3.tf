# Create a bucket for terraform remote state
resource "aws_s3_bucket" "terraform_remote_state" {
  count = var.create_s3_bucket_remote_state ? 1 : 0

  bucket = "${var.customer}-terraform-remote-state"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name       = "terraform-remote-state"
    client     = var.customer
    project    = var.project
    env        = var.env
    "cycloid.io" = "true"
  }
}

