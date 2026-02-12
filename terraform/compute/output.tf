output "jenkins_public_ip" {
  description = "Public IP of the Jenkins Server"
  value       = aws_instance.jenkins_server.public_ip
}

output "app_public_ip" {
  description = "Public IP of the App Server"
  value       = aws_instance.app_server.public_ip
}

output "jenkins_instance_id" {
  description = "Instance ID of the Jenkins Server"
  value       = aws_instance.jenkins_server.id
}

output "app_instance_id" {
  description = "Instance ID of the App Server"
  value       = aws_instance.app_server.id
}
