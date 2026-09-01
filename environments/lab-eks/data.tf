data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "terraform_remote_state" "lab_network" {
  backend = "s3"

  config = {
    bucket = var.network_state_bucket
    key    = var.network_state_key
    region = var.aws_region
  }
}
