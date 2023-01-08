output "firewall_public_ip" {
    value = "Firewall Public IP: ${azurerm_public_ip.firewallpip.ip_address}"
}