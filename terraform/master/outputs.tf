output "address_agent" {
  value = "${aws_instance.jenkins_master.public_dns}"
}