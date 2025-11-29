output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.webserver.id
}

output "instance_private_ip" {
  description = "Private IP address of the instance"
  value       = aws_instance.webserver.private_ip
}

output "instance_public_ip" {
  description = "Public IP address of the instance"
  value       = aws_instance.webserver.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the instance"
  value       = aws_instance.webserver.public_dns
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/icg/${var.key_pair_name}.pem ec2-user@${aws_instance.webserver.public_ip}"
}

output "webserver_domain" {
  description = "webserver domain name (Route 53 subdomain)"
  value       = aws_route53_record.webserver_subdomain.fqdn
}

output "webserver_domain_url" {
  description = "webserver URL using domain name (HTTPS)"
  value       = "https://${aws_route53_record.webserver_subdomain.fqdn}"
}

output "elastic_ip" {
  description = "Elastic IP address"
  value       = aws_eip.webserver_eip.public_ip
}

output "target_group_name" {
  description = "Name of the Target Group"
  value       = aws_lb_target_group.webserver.name
}

output "ssh_cidr_resolved" {
  description = "Resolved SSH CIDR block (current workstation IP if ssh_cidr was 0.0.0.0/0)"
  value       = local.ssh_cidr
}

output "current_workstation_ip" {
  description = "Current workstation public IP address"
  value       = chomp(data.http.current_ip.response_body)
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = var.cloudfront_distro ? aws_cloudfront_distribution.webserver[0].id : null
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = var.cloudfront_distro ? aws_cloudfront_distribution.webserver[0].domain_name : null
}

output "cloudfront_url" {
  description = "CloudFront distribution URL"
  value       = var.cloudfront_distro ? "https://${aws_cloudfront_distribution.webserver[0].domain_name}" : null
}
