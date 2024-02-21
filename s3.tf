resource "aws_s3_bucket" "user_data" {
  bucket = var.user_data_bucket_name
}

resource "aws_s3_bucket_ownership_controls" "user_data_ownership" {
  bucket = aws_s3_bucket.user_data.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "user_data_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.user_data_ownership]

  bucket = aws_s3_bucket.user_data.id
  acl    = "private"
}

resource "aws_s3_object" "web_user_data" {
  bucket  = aws_s3_bucket.user_data.id
  key     = "web_user_data.sh"
  content = templatefile("${path.module}/templates/web_user_data.sh", local.web_interpolation_vars)
}

resource "aws_s3_object" "worker_user_data" {
  bucket  = aws_s3_bucket.user_data.id
  key     = "worker_user_data.sh"
  content = templatefile("${path.module}/templates/worker_user_data.sh", local.worker_interpolation_vars)
}
