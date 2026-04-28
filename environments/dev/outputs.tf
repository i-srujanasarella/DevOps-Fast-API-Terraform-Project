output "application_url" {
  description = "FastAPI application URL"
  value       = module.infrastructure.application_url
}

output "instance_public_ip" {
  description = "Public IP"
  value       = module.infrastructure.instance_public_ip
}