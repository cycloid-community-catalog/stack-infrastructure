# Here is an example of dummy terraform resource
# https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource
resource "null_resource" "instance" {
  triggers = {
    name = "${var.project}-${var.env}"
    type = var.instance_type
  }
}
