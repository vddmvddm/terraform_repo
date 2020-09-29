output "alb_dns_name" {
  value       = module.web-cluster.alb_dns_name
  description = "The domain name of the load balancer"
}
