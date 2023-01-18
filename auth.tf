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
    }
  }
  EOF
}

resource "aws_api_gateway_request_validator" "mockSantanderAuthRequestValidator" {
  name                        = "AuthRequestValidator"
  rest_api_id                 = aws_api_gateway_rest_api.mockSantander.id
  validate_request_body       = true
  validate_request_parameters = true
}

resource "aws_api_gateway_integration" "mockSantanderAuthIntegration" {
  rest_api_id = aws_api_gateway_rest_api.mockSantander.id
  resource_id = aws_api_gateway_resource.mockSantanderResourceToken.id
  http_method = aws_api_gateway_method.mockSantanderAuthMethod.http_method
  request_templates = {
    "application/json" = <<EOF
      {
        #if( $input.params('grant_type') == "client_credentials" )
          "statusCode": 200
        #else
          "statusCode": 500
        #end
      }
    EOF
  }
  request_parameters = { "integration.request.querystring.grant_type" = "'method.request.querystring.grant_type'" }
  type               = "MOCK"
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

resource "aws_api_gateway_method_response" "mockSantanderAuthResponse500" {
  rest_api_id = aws_api_gateway_rest_api.mockSantander.id
  resource_id = aws_api_gateway_resource.mockSantanderResourceToken.id
  http_method = aws_api_gateway_method.mockSantanderAuthMethod.http_method
  status_code = "500"
  response_models = {
    "application/json" = aws_api_gateway_model.mockSantanderAuthResponseModel.name
  }
}

resource "aws_api_gateway_integration_response" "mockSantanderAuthIntegrationResponse500" {
  rest_api_id       = aws_api_gateway_rest_api.mockSantander.id
  resource_id       = aws_api_gateway_resource.mockSantanderResourceToken.id
  http_method       = aws_api_gateway_method.mockSantanderAuthMethod.http_method
  status_code       = aws_api_gateway_method_response.mockSantanderAuthResponse500.status_code
  selection_pattern = "5\\d{2}"
}

resource "aws_api_gateway_method" "mockSantanderAuthMethod" {
  rest_api_id          = aws_api_gateway_rest_api.mockSantander.id
  resource_id          = aws_api_gateway_resource.mockSantanderResourceToken.id
  http_method          = "POST"
  authorization        = "NONE"
  request_validator_id = aws_api_gateway_request_validator.mockSantanderAuthRequestValidator.id
  request_parameters   = { "method.request.querystring.grant_type" = true }
}
