// S3 bucket for storing images
resource "aws_s3_bucket" "image_bucket" {
  bucket = "my-stable-diffusion-images"
}

resource "aws_s3_bucket_public_access_block" "image_bucket_public_access_block" {
  bucket = aws_s3_bucket.image_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "image_bucket_policy" {
  bucket = aws_s3_bucket.image_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.image_bucket.arn}/*"
      }
    ]
  })
}
