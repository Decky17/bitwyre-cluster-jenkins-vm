data "terraform_remote_state" "vpc_state" {
  backend   = "gcs"
  workspace = terraform.workspace
  config = {
    bucket = "gcs-asia-northeast1-devops"
    prefix = "bitwyre-cluster-vpc"
  }
}