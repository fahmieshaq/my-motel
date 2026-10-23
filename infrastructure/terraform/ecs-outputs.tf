output "ecs_cluster_name" {
  description = "Name of the Motel API ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "ARN of the Motel API ECS cluster"
  value       = aws_ecs_cluster.main.arn
}
