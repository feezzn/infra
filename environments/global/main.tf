terraform {
  backend "s3" {
    bucket         = "felipe-tfstate-660830512266-v2"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-v2"
    encrypt        = true
  }
}

provider "aws" {
  alias  = "billing"
  region = "us-east-1"
}

resource "aws_budgets_budget" "monthly_budget_global" {
  provider = aws.billing

  name         = "global-monthly-budget"
  budget_type  = "COST"
  limit_amount = "20" # aqui você define o total (ex: 20 USD)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["feeelipe.silva@gmail.com"]
  }
}