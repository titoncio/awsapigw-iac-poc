resource "aws_api_gateway_model" "mockSantanderAuthResponseModel" {
  rest_api_id  = aws_api_gateway_rest_api.mockSantander.id
  name         = "AuthResponseModel"
  content_type = "application/json"

  schema = <<EOF
  {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
      "access_token": {
        "type": "string"
      }
    },
    "required": [
      "access_token"
    ]
  }
  EOF
}

resource "aws_api_gateway_integration" "mockSantanderAuthIntegration" {
  rest_api_id = aws_api_gateway_rest_api.mockSantander.id
  resource_id = aws_api_gateway_resource.mockSantanderResourceToken.id
  http_method = aws_api_gateway_method.mockSantanderAuthMethod.http_method
  request_templates = {
    "application/json" = <<EOF
      {
        "statusCode": 200
      }
    EOF
  }
  type = "MOCK"
}

resource "aws_api_gateway_method_response" "mockSantanderAuthResponse200" {
  rest_api_id = aws_api_gateway_rest_api.mockSantander.id
  resource_id = aws_api_gateway_resource.mockSantanderResourceToken.id
  http_method = aws_api_gateway_method.mockSantanderAuthMethod.http_method
  status_code = "200"
  response_models = {
    "application/json" = aws_api_gateway_model.mockSantanderAuthResponseModel.name
  }
}

resource "aws_api_gateway_integration_response" "mockSantanderAuthIntegrationResponse200" {
  rest_api_id = aws_api_gateway_rest_api.mockSantander.id
  resource_id = aws_api_gateway_resource.mockSantanderResourceToken.id
  http_method = aws_api_gateway_method.mockSantanderAuthMethod.http_method
  status_code = aws_api_gateway_method_response.mockSantanderAuthResponse200.status_code

  response_templates = {
    "application/json" = <<EOF
      {
        "access_token": "mockAccessToken"
      }
    EOF
  }
}

resource "aws_api_gateway_method" "mockSantanderAuthMethod" {
  rest_api_id   = aws_api_gateway_rest_api.mockSantander.id
  resource_id   = aws_api_gateway_resource.mockSantanderResourceToken.id
  http_method   = "POST"
  authorization = "NONE"
}
