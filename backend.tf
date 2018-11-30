# ------------------------------------------------------------------------------
# Module: backend.tf
#
# Description: s3 backend configuration for storing tfstate
# ------------------------------------------------------------------------------
terraform {
  ### unfortunately have to hard code backend config as interpolation fails :-(
  ### you only need to modify the key (path to store the state file)
  backend "s3" {
    bucket = "your bucket name here"
    key = "path to your key here"
    region = "us-east-1"
    encrypt = true
    kms_key_id = "the arn to the kms key for the bucket"
    role_arn = "the role that will be assumed for this"
  }
}
