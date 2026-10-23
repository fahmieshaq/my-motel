# ------------------------------------------------------------
# ECS Task Definition Outputs - Motel API
# ------------------------------------------------------------

output "motel_api_task_definition_arn" {
  description = "ARN of the Motel API ECS task definition"
  value       = aws_ecs_task_definition.hotel_api.arn
}

output "motel_api_task_definition_family" {
  description = "Family name of the Motel API task definition"
  value       = aws_ecs_task_definition.hotel_api.family
}

output "motel_api_task_definition_revision" {
  description = "Revision number of the Motel API task definition"
  value       = aws_ecs_task_definition.hotel_api.revision
}
