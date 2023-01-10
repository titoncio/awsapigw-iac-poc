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

resource "aws_api_gateway_rest_api" "mockSantander" {
  name        = "mockSantander"
  description = "Mock Santander made with TF"
}

resource "aws_api_gateway_resource" "mockSantanderResourceApi" {
  rest_api_id = aws_api_gateway_rest_api.mockSantander.id
  parent_id   = aws_api_gateway_rest_api.mockSantander.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_model" "mockSantanderCreateBillingRequest" {
  rest_api_id  = aws_api_gateway_rest_api.mockSantander.id
  name         = "CreateBillingRequest"
  content_type = "application/json"

  schema = <<EOF
  {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
      "calendario": {
        "type": "object",
        "properties": {
          "expiracao": {
            "type": "string"
          },
          "criacao": {
            "type": "string"
          }
        },
        "required": [
          "expiracao"
        ]
      },
      "valor": {
        "type": "object",
        "properties": {
          "original": {
            "type": "string"
          }
        },
        "required": [
          "original"
        ]
      },
      "chave": {
        "type": "string"
      }
    },
    "required": [
      "calendario",
      "valor",
      "chave"
    ]
  }
EOF
}

resource "aws_api_gateway_resource" "mockSantanderResourceV1" {
  rest_api_id = aws_api_gateway_rest_api.mockSantander.id
  parent_id   = aws_api_gateway_resource.mockSantanderResourceApi.id
  path_part   = "v1"
}

resource "aws_api_gateway_resource" "mockSantanderResourceCob" {
  rest_api_id = aws_api_gateway_rest_api.mockSantander.id
  parent_id   = aws_api_gateway_resource.mockSantanderResourceV1.id
  path_part   = "cob"
}

resource "aws_api_gateway_resource" "mockSantanderResourceTxId" {
  rest_api_id = aws_api_gateway_rest_api.mockSantander.id
  parent_id   = aws_api_gateway_resource.mockSantanderResourceCob.id
  path_part   = "{txid}"
}

resource "aws_api_gateway_method" "mockSantanderGetBillingMethod" {
  rest_api_id   = aws_api_gateway_rest_api.mockSantander.id
  resource_id   = aws_api_gateway_resource.mockSantanderResourceTxId.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "mockSantanderCreateBillingMethod" {
  rest_api_id   = aws_api_gateway_rest_api.mockSantander.id
  resource_id   = aws_api_gateway_resource.mockSantanderResourceTxId.id
  http_method   = "PUT"
  authorization = "NONE"
  request_models = aws_api_gateway_method.mockSantanderGetBillingMethod.request_models
}

resource "aws_api_gateway_integration" "mockSantanderCreateBillingIntegration" {
  rest_api_id = aws_api_gateway_rest_api.mockSantander.id
  resource_id = aws_api_gateway_resource.mockSantanderResourceTxId.id
  http_method = aws_api_gateway_method.mockSantanderCreateBillingMethod.http_method
  request_templates = {
    "application/json" = <<-EOT
      {
        #if( $input.params('Authorization') == "Bearer mockAuthorization" )
          "statusCode": 200
        #else
          "statusCode": 500
        #end
      }
    EOT
  }
  type        = "MOCK"
}

resource "aws_api_gateway_method_response" "mockSantanderCreateBillingResponse200" {
  rest_api_id = aws_api_gateway_rest_api.mockSantander.id
  resource_id = aws_api_gateway_resource.mockSantanderResourceTxId.id
  http_method = aws_api_gateway_method.mockSantanderCreateBillingMethod.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "mockSantanderCreateBillingResponse" {
  rest_api_id = aws_api_gateway_rest_api.mockSantander.id
  resource_id = aws_api_gateway_resource.mockSantanderResourceTxId.id
  http_method = aws_api_gateway_method.mockSantanderCreateBillingMethod.http_method
  status_code = aws_api_gateway_method_response.mockSantanderCreateBillingResponse200.status_code

  # Transforms the backend JSON response to XML
  response_templates = {
    "application/json" = <<EOF
  #set($inputRoot = $input.path('$'))
  {
    $inputRoot.body
  }
  EOF
  }
}


resource "aws_api_gateway_method_response" "mockSantanderCreateBillingResponse500" {
  rest_api_id = aws_api_gateway_rest_api.mockSantander.id
  resource_id = aws_api_gateway_resource.mockSantanderResourceTxId.id
  http_method = aws_api_gateway_method.mockSantanderCreateBillingMethod.http_method
  status_code = "500"
}

# resource "aws_api_gateway_integration" "mockSantanderIntegration" {
#   rest_api_id          = aws_api_gateway_rest_api.mockSantander.id
#   resource_id          = aws_api_gateway_resource.mockSantanderResourceTxId.id
#   http_method          = aws_api_gateway_method.mockSantanderMethod.http_method
#   type                 = "MOCK"
#   cache_namespace      = "foobar"
#   timeout_milliseconds = 29000

#   request_parameters = {
#     "integration.request.header.Authorization" = "'static'"
#   }

#   request_templates = {
#     "application/json" = <<EOF
#   #set($inputRoot = $input.path('$'))
#   {
#     "statusCode": 200,
#     "calendario" : {
#       "expiracao" : "foo",
#       "criacao" : "foo"
#     },
#     "valor" : {
#       "original" : "foo"
#     },
#     "chave" : $util.escapeJavaScript($input.json('$'))
#   }
# EOF
#   }
# }
