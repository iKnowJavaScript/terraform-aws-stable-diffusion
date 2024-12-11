# Key pairs
resource "tls_private_key" "generated_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${local.name}-key-${local.environment}"
  public_key = tls_private_key.generated_key.public_key_openssh
}

output "private_key_pem" {
  value     = tls_private_key.generated_key.private_key_pem
  sensitive = true
}

output "s3" {
  value = aws_s3_bucket.image_bucket.bucket
}