################################################
# I'm using a role, rather than a profile as the pipeline will not have a aws config and credentials file, although that is an option
# See AWS SDK Environment Variables for more info https://docs.aws.amazon.com/cli/latest/userguide/cli-environment.html
################################################
provider "aws" {
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::761602949203:role/OrganizationAccountAccessRole"
  }
}
