# **************************** REMOTE BACKEND!! Removed from the state *****************************

resource "aws_s3_bucket" "terraform_state_eks_portfolio" {
  bucket = "portfolio-s3-backend-state-bucket-eu-west-2"

  lifecycle {
    prevent_destroy = true
  }
  tags = merge(tomap({ "Name" = "Terraform State Bucket N. Virginia region" }), var.permanent_tags)
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_eks_portfolio" {
  bucket = aws_s3_bucket.terraform_state_eks_portfolio.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_eks_portfolio" {
  bucket = aws_s3_bucket.terraform_state_eks_portfolio.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state_eks_portfolio" {
  bucket = aws_s3_bucket.terraform_state_eks_portfolio.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
