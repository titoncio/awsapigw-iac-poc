terraform {
  required_version = ">= 0.12"
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.mockSantander.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.mockSantanderResourceTxId.id,
      aws_api_gateway_method.mockSantanderCreateBillingMethod.id,
      aws_api_gateway_integration.mockSantanderCreateBillingIntegration.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.mockSantander.id
  stage_name    = "dev"
}
