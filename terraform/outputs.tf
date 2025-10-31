output "vm_external_ip" {
  description = "External IP address of the WordPress VM"
  value       = google_compute_instance.wordpress_vm.network_interface[0].access_config[0].nat_ip
}

output "vm_internal_ip" {
  description = "Internal IP address of the WordPress VM"
  value       = google_compute_instance.wordpress_vm.network_interface[0].network_ip
}

output "vm_name" {
  description = "Name of the WordPress VM"
  value       = google_compute_instance.wordpress_vm.name
}

output "vpc_name" {
  description = "Name of the VPC"
  value       = google_compute_network.wordpress_vpc.name
}

output "subnet_name" {
  description = "Name of the subnet"
  value       = google_compute_subnetwork.wordpress_subnet.name
}

output "wordpress_url" {
  description = "URL to access WordPress"
  value       = "http://${google_compute_instance.wordpress_vm.network_interface[0].access_config[0].nat_ip}:8080"
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "gcloud compute ssh --project ${var.project_id} --zone ${var.zone} ${google_compute_instance.wordpress_vm.name}"
}