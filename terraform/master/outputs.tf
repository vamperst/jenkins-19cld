output "address_master" {
  value = "jenkins: ${aws_instance.jenkins_master.public_dns}:8080"
}