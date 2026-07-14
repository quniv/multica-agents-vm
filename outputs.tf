output "domain_name" {
  description = "Libvirt domain name."
  value       = libvirt_domain.agent_vm.name
}

output "ipv4_address" {
  description = "DHCP IPv4 address assigned by libvirt."
  value       = try(libvirt_domain.agent_vm.network_interface[0].addresses[0], null)
}

output "ssh_command" {
  description = "Key-only SSH command for the ubuntu user."
  value       = "ssh -o IdentitiesOnly=yes -o PasswordAuthentication=no -i ${local.ssh_private_key_path} ubuntu@${try(libvirt_domain.agent_vm.network_interface[0].addresses[0], "<guest-ip>")}"
}
