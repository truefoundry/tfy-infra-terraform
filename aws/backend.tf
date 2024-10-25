terraform {
  backend "s3" {
    bucket = "harshit-poc"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
