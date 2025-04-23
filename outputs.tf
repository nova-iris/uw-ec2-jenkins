output "jenkins_public_ip" {
  value = module.jenkins_server.public_ip
}

output "jenkins_private_ip" {
  value = module.jenkins_server.private_ip
}

output "jenkins_instance_id" {
  value = module.jenkins_server.id
}
