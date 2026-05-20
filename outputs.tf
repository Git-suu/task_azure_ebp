output "frontend_public_ip" {
  value = azurerm_public_ip.frontend_pip.ip_address
}

output "frontend_url" {
  value = "http://${azurerm_public_ip.frontend_pip.ip_address}"
}