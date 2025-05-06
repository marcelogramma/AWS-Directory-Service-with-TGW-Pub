terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  alias      = "operaciones"
  region     = var.region
  access_key = var.aws_access_key_operaciones
  secret_key = var.aws_secret_key_operaciones
}

provider "aws" {
  alias      = "dev"
  region     = var.region
  access_key = var.aws_access_key_dev
  secret_key = var.aws_secret_key_dev
}

provider "aws" {
  alias      = "stage"
  region     = var.region
  access_key = var.aws_access_key_stage
  secret_key = var.aws_secret_key_stage
}

provider "aws" {
  alias      = "prod"
  region     = var.region
  access_key = var.aws_access_key_prod
  secret_key = var.aws_secret_key_prod
}
