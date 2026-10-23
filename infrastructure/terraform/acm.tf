# ------------------------------------------------------------
# AWS Certificate Manager
# HTTPS certificate for Hotel API staging and production
# ------------------------------------------------------------

resource "aws_acm_certificate" "hotel_api" {
  domain_name = "api.collegeboox.com"

  subject_alternative_names = [
    "staging-api.collegeboox.com"
  ]

  validation_method = "DNS"

  tags = {
    Name        = "${var.application_name}-https"
    Application = var.application_name
    ManagedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}
