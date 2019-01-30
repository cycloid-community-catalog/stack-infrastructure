resource "aws_key_pair" "deployment" {
  key_name   = "${var.keypair_name}"
  public_key = "${var.keypair_public}"
}
