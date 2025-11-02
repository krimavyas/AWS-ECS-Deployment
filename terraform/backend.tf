terraform {
  backend "s3" {
    bucket         = "<bucket-name>"    # Create this S3 bucket in your account
    key            = "<path to store terraform.tfstate>"
    region         = "<region-name>"
    encrypt        = true
  }
}
