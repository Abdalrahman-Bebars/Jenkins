terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        }
    }
}
provider "aws" {
    shared_config_files      = ["conf"]
    shared_credentials_files = ["creds"]
}


