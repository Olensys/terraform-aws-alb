output "id" {
  description = "ID of the load balancer. Null when create is false."
  value       = var.create ? module.this.id : null
}

output "name" {
  description = "Name of the load balancer. Null when create is false."
  value       = var.create ? var.name : null
}

output "arn" {
  description = "ARN of the load balancer. Null when create is false."
  value       = var.create ? module.this.arn : null
}

output "dns_name" {
  description = "DNS name of the load balancer. Null when create is false."
  value       = var.create ? module.this.dns_name : null
}

output "zone_id" {
  description = "Route 53 hosted zone ID of the load balancer, for alias records. Null when create is false."
  value       = var.create ? module.this.zone_id : null
}

output "https_listener_arn" {
  description = "ARN of the HTTPS:443 listener, the attachment point for listener rules. Null when create is false."
  value       = var.create ? module.this.listeners["https"].arn : null
}

output "security_group_id" {
  description = "ID of the security group managed by this module. Null when create is false."
  value       = var.create ? module.this.security_group_id : null
}

output "tags" {
  description = "Tags applied to every taggable resource, with context.extra_tags merged in. Null when create is false."
  value       = var.create ? local.tags : null
}

output "listener_config" {
  description = "Listener configuration passed to the upstream module (no secrets). Null when create is false."
  value = var.create ? {
    for k, v in local.listeners : k => {
      for a, b in v : a => b if a != "certificate_arn" && a != "additional_certificate_arns"
    }
  } : null

  precondition {
    condition     = !var.create || var.certificate_arn != null
    error_message = "certificate_arn is required when create is true: this module is HTTPS-only."
  }
}

output "deletion_protection_enabled" {
  description = "Whether deletion protection is requested (true in prod). Null when create is false."
  value       = var.create ? local.deletion_protection : null
}

output "ssl_policy" {
  description = "TLS policy applied to the HTTPS listener. Null when create is false."
  value       = var.create ? local.ssl_policy : null
}
