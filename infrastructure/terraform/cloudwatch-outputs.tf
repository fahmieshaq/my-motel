# ------------------------------------------------------------
# CloudWatch Outputs - Motel API
# ------------------------------------------------------------

output "motel_api_log_group_name" {
  description = "CloudWatch log group name for Motel API"
  value       = aws_cloudwatch_log_group.app.name
}

output "motel_api_log_group_arn" {
  description = "CloudWatch log group ARN for Motel API"
  value       = aws_cloudwatch_log_group.app.arn
}
