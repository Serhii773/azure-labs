output "container_fqdn" {
  value       = azurerm_container_group.az104_c1.fqdn
  description = "URL для доступу до контейнера"
}

output "container_ip" {
  value       = azurerm_container_group.az104_c1.ip_address
  description = "Публічна IP адреса контейнера"
}
