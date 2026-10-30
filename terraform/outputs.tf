output "node_ip" {
  description = "Host IP for SSH access"
  value       = "127.0.0.1"
}

output "node_ports" {
  description = "Mapped SSH ports for provisioned container nodes"
  value       = [for c in docker_container.target_nodes : c.ports[0].external]
}

output "ansible_inventory_format" {
  description = "Quick copy-paste lines for inventory.ini"
  value = [
    for i, c in docker_container.target_nodes :
    "${c.name} ansible_host=127.0.0.1 ansible_port=${c.ports[0].external} ansible_user=root ansible_password=root"
  ]
}