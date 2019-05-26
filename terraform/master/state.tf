terraform {
  backend "s3" {
    bucket = "18cld-teste-prod"
    key    = "test-jenkins-master"
    region = "us-east-1"
  }
}
