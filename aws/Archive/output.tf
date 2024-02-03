output "ubuntu_instance_public_ips" {
  value       = aws_instance.ubuntu_server.*.public_ip
  description = "Public IP addresses of the Ubuntu instances"
}

output "check_point_manager_public_ips" {
  value       = aws_instance.vpc_instance.*.public_ip
  description = "Public IP addresses of the Check Point Manager instances"
}
