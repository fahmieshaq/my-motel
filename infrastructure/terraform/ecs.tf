
# ------------------------------------------------------------
# Shared ECS Cluster
# ------------------------------------------------------------

resource "aws_ecs_cluster" "main" {
  name = "${var.application_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = {
    Name = "${var.application_name}-cluster"
  }
}
