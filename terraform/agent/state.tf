terraform {
  backend "s3" {
    bucket = "18cld-teste-prod"
    key    = "test-jenkins-agent"
    region = "us-east-1"
  }
}
