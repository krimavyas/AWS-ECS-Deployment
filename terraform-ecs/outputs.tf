output "alb_dns_name" {
  description = "Public DNS of the ALB"
  value       = module.alb.alb_dns_name
}
output "ecr_repository_url" {
  value = module.ecr.repository_url
}