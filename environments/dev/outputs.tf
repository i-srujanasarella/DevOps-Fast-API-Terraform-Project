output "app_url" {
  description = "FastAPI app URL"
  value       = module.infrastructure.app_url
}

output "instance_public_ip" {
  description = "Public IP"
  value       = module.infrastructure.instance_public_ip
}