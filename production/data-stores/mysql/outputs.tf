output "db_address" {
  value       = module.mysql.address
  description = "The domain name of the load balancer"
}

output "db_port" {
  value       = module.mysql.port
  description = "The domain name of the load balancer"
}
