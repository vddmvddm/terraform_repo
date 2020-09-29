output "address" {
  value       = module.mysql.address
  description = "The domain name of the load balancer"
}

output "port" {
  value       = module.mysql.port
  description = "The domain name of the load balancer"
}
