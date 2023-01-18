resource "aws_api_gateway_model" "mockSantanderRefundBillingRequestModel" {
  rest_api_id  = aws_api_gateway_rest_api.mockSantander.id
  name         = "RefundBillingRequestModel"
  content_type = "application/json"

  schema = <<EOF
  {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
      "valor": {
        "type": "string"
      }
    },
    "required": [
      "valor"
    ]
  }
  EOF
}

resource "aws_api_gateway_request_validator" "mockSantanderRefundBillingRequestValidator" {
  name                        = "RefundBillingRequestValidator"
  rest_api_id                 = aws_api_gateway_rest_api.mockSantander.id
  validate_request_body       = true
  validate_request_parameters = true
}

resource "aws_api_gateway_model" "mockSantanderRefundBillingResponseModel" {
  rest_api_id  = aws_api_gateway_rest_api.mockSantander.id
  name         = "RefundBillingResponseModel"
  content_type = "application/json"

  schema = <<EOF
  {
  "$schema": "http://json-schema.org/draft-04/schema#",
  "type": "object",
  "properties": {
    "id": {
      "type": "string"
    },
    "rtrId": {
      "type": "string"
    },
    "valor": {
      "type": "string"
    },
    "horario": {
      "type": "object",
      "properties": {
        "solicitacao": {
          "type": "string"
        },
        "liquidacao": {
          "type": "string"
        }
      },
      "required": [
        "solicitacao",
        "liquidacao"
      ]
    },
    "status": {
      "type": "string"
    },
    "motivo": {
      "type": "string"
    }
  },
  "required": [
    "id",
    "rtrId",
    "valor",
    "horario",
    "status",
    "motivo"
  ]
  }
  EOF
}

resource "aws_api_gateway_integration" "mockSantanderRefundBillingIntegration" {
  rest_api_id = aws_api_gateway_rest_api.mockSantander.id
  resource_id = aws_api_gateway_resource.mockSantanderResourceDevolucao.id
  http_method = aws_api_gateway_method.mockSantanderRefundBillingMethod.http_method
  request_templates = {
    "application/json" = <<EOF
      {
        "statusCode": 200,
        "body" : $util.escapeJavaScript($input.json('$'))
      }
    EOF
  }
  request_parameters = { "integration.request.header.refundId" = "'method.request.header.refundId'" }
  type               = "MOCK"
}

resource "aws_api_gateway_integration_response" "mockSantanderRefundBillingIntegrationResponse200" {
  rest_api_id = aws_api_gateway_rest_api.mockSantander.id
  resource_id = aws_api_gateway_resource.mockSantanderResourceDevolucao.id
  http_method = aws_api_gateway_method.mockSantanderRefundBillingMethod.http_method
  status_code = aws_api_gateway_method_response.mockSantanderRefundBillingResponse200.status_code

  response_templates = {
    "application/json" = <<EOF
      #set($inputRoot = $input.path('$'))
      {
        "id": "mockId",
        "rtrId": "mockRtrId",
        "valor": "mockValor",
        "horario": {
          "solicitacao": "mockHorarioSolicitacao",
          "liquidacao": "mockHorarioLiquidacao"
        },
        "status": "DEVOLVIDO",
        "motivo": "mockMotivo"
      }
    EOF
  }
}

resource "aws_api_gateway_method_response" "mockSantanderRefundBillingResponse200" {
  rest_api_id = aws_api_gateway_rest_api.mockSantander.id
  resource_id = aws_api_gateway_resource.mockSantanderResourceDevolucao.id
  http_method = aws_api_gateway_method.mockSantanderRefundBillingMethod.http_method
  status_code = "200"
  response_models = {
    "application/json" = aws_api_gateway_model.mockSantanderRefundBillingResponseModel.name
  }
}

resource "aws_api_gateway_method" "mockSantanderRefundBillingMethod" {
  rest_api_id          = aws_api_gateway_rest_api.mockSantander.id
  resource_id          = aws_api_gateway_resource.mockSantanderResourceDevolucao.id
  http_method          = "PUT"
  authorization        = "NONE"
  request_validator_id = aws_api_gateway_request_validator.mockSantanderRefundBillingRequestValidator.id
  request_models = {
    "application/json" = aws_api_gateway_model.mockSantanderRefundBillingRequestModel.name
  }
  request_parameters = { "method.request.querystring.refundId" = true }
}
