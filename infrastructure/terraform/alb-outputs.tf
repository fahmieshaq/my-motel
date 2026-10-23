
output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_url" {
  description = "Temporary HTTP URL for Motel API"
  value       = "http://${aws_lb.main.dns_name}"
}

output "motel_api_target_group_arn" {
  description = "Target group ARN used by the Motel API ECS service"
  value       = aws_lb_target_group.hotel_api.arn
}
