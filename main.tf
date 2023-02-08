# Configure terraform
terraform {
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "~> 3.13.0"
    }
  }
}


# Configure the New Relic provider
provider "newrelic" {
  account_id = var.account_id
  api_key = var.api_key
}