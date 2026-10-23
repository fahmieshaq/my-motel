locals {
  #github_repository = "fahmieshaq/my-hotel"
  github_repository = "fahmieshaq/my-motel"

  github_deployment_roles = {
    staging = {
      environment = "staging"
      #       service     = "hotel-api-staging"
      service = "my-motel-staging"
    }
    prod = {
      environment = "production"
      #       service     = "hotel-api-prod"
      service = "my-motel-prod"
    }
  }
}

data "aws_iam_policy_document" "github_deployment_trust" {
  for_each = local.github_deployment_roles

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      identifiers = [
        #aws_iam_openid_connect_provider.github.arn
        data.aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        #"repo:fahmieshaq@22756125/my-hotel@1411763878:environment:${each.value.environment}"
        "repo:${local.github_repository}:environment:${each.value.environment}"
      ]
    }
  }
}

resource "aws_iam_role" "github_deployer" {
  for_each = local.github_deployment_roles

  #   name = each.key == "prod" ? (
  #     "hotel-api-github-production-deployer"
  #     ) : (
  #     "hotel-api-github-staging-deployer"
  #   )

  name = "${var.application_name}-github-${each.value.environment}-deployer"

  assume_role_policy = data.aws_iam_policy_document.github_deployment_trust[
    each.key
  ].json
}

resource "aws_iam_role_policy" "github_deployer" {
  for_each = local.github_deployment_roles

  #   name = "hotel-api-ecs-deploy"
  name = "${var.application_name}-ecs-deploy"
  role = aws_iam_role.github_deployer[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid      = "DescribeTaskDefinitions"
        Effect   = "Allow"
        Action   = ["ecs:DescribeTaskDefinition"]
        Resource = "*"
      },
      {
        Sid    = "RegisterEnvironmentTaskDefinitions"
        Effect = "Allow"
        Action = ["ecs:RegisterTaskDefinition"]
        Resource = [
          #"arn:aws:ecs:eu-west-2:343482277554:task-definition/hotel-api-${each.key}:*"
          "arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:task-definition/${var.application_name}-${each.key}:*"
        ]
      },
      {
        Sid    = "ManageEnvironmentService"
        Effect = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:UpdateService"
        ]
        Resource = [
          #"arn:aws:ecs:eu-west-2:343482277554:service/shared-apps-cluster/${each.value.service}"
          "arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:service/${aws_ecs_cluster.main.name}/${each.value.service}"
        ]
      },
      {
        Sid    = "PassEnvironmentTaskRoles"
        Effect = "Allow"
        Action = ["iam:PassRole"]

        Resource = [
          aws_iam_role.hotel_api_task.arn,
          aws_iam_role.hotel_api_environment_execution[
            each.key
          ].arn
        ]

        Condition = {
          StringEquals = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      }
    ]
  })
}
