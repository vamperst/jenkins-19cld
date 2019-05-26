output "address_agent" {
  value = "${aws_instance.jenkins_agent.public_dns}"
}