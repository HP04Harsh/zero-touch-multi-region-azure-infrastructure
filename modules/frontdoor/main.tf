# 1. Front Door Profile
resource "azurerm_cdn_frontdoor_profile" "fd_profile" {
  name                = "global-web-access"
  resource_group_name = var.resource_group_name
  sku_name            = "Standard_AzureFrontDoor"
}

# 2. Endpoint (The URL users will visit)
resource "azurerm_cdn_frontdoor_endpoint" "endpoint" {
  name                     = "global-web-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd_profile.id
}

# 3. Origin Group (The cluster of your two VMs)
resource "azurerm_cdn_frontdoor_origin_group" "origin_group" {
  name                     = "webapp-origin-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd_profile.id
  session_affinity_enabled = false

  health_probe {
    interval_in_seconds = 30
    path                = "/"
    protocol            = "Http"
    request_type        = "HEAD"
  }

  load_balancing {
    additional_latency_in_milliseconds = 50
    sample_size                        = 4
    successful_samples_required        = 3
  }
}

# 4. India Origin
resource "azurerm_cdn_frontdoor_origin" "india_origin" {
  name                          = "india-vm"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id
  enabled                       = true
  certificate_name_check_enabled = false

  host_name          = var.india_vm_ip
  http_port          = 80
  https_port         = 443
  priority           = 1  # 1 is primary
  weight             = 100
}

# 5. US Origin
resource "azurerm_cdn_frontdoor_origin" "us_origin" {
  name                          = "us-vm"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id
  enabled                       = true
  certificate_name_check_enabled = false

  host_name          = var.us_vm_ip
  http_port          = 80
  https_port         = 443
  priority           = 2  # 2 is secondary (Failover)
  weight             = 100
}

# 6. Route (Connects Endpoint to Origin Group)
resource "azurerm_cdn_frontdoor_route" "route" {
  name                          = "global-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.india_origin.id, azurerm_cdn_frontdoor_origin.us_origin.id]

  supported_protocols    = ["Http", "Https"]
  patterns_to_match      = ["/*"]
  forwarding_protocol    = "HttpOnly"
  link_to_default_domain = true
}

output "frontdoor_url" {
  value = azurerm_cdn_frontdoor_endpoint.endpoint.host_name
}