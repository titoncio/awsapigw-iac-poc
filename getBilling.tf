resource "aws_api_gateway_model" "mockSantanderGetBillingResponseModel" {
  rest_api_id  = aws_api_gateway_rest_api.mockSantander.id
  name         = "GetBillingResponseModel"
  content_type = "application/json"

  schema = <<EOF
  {
  "$schema": "http://json-schema.org/draft-04/schema#",
  "type": "object",
  "properties": {
    "status": {
      "type": "string"
    },
    "txid": {
      "type": "string"
    },
    "calendario": {
      "type": "object",
      "properties": {
        "criacao": {
          "type": "string"
        },
        "expiracao": {
          "type": "string"
        }
      },
      "required": [
        "criacao",
        "expiracao"
      ]
    },
    "location": {
      "type": "string"
    },
    "revisao": {
      "type": "string"
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
    },
    "pix": {
      "type": "array",
      "items": [
        {
          "type": "object",
          "properties": {
            "endToEndId": {
              "type": "string"
            },
            "txid": {
              "type": "string"
            },
            "valor": {
              "type": "string"
            },
            "horario": {
              "type": "string"
            }
          },
          "required": [
            "endToEndId",
            "txid",
            "valor",
            "horario"
          ]
        }
      ]
    },
    "devolucoes": {
      "type": "array",
      "items": [
        {
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
            }
          },
          "required": [
            "id",
            "rtrId",
            "valor",
            "horario",
            "status"
          ]
        }
      ]
    },
    "infoAdicionais": {
      "type": "array",
      "items": {}
    }
  },
  "required": [
    "status",
    "txid",
    "calendario",
    "location",
    "revisao",
    "valor",
    "chave",
    "pix"
  ]
  }
  EOF
}

resource "aws_api_gateway_request_validator" "mockSantanderGetBillingRequestValidator" {
  name                        = "GetBillingRequestValidator"
  rest_api_id                 = aws_api_gateway_rest_api.mockSantander.id
  validate_request_parameters = true
}

resource "aws_api_gateway_integration" "mockSantanderGetBillingIntegration" {
  rest_api_id = aws_api_gateway_rest_api.mockSantander.id
  resource_id = aws_api_gateway_resource.mockSantanderResourceTxId.id
  http_method = aws_api_gateway_method.mockSantanderGetBillingMethod.http_method
  request_templates = {
    "application/json" = <<EOF
      {
        "statusCode": 200
      }
    EOF
  }
  request_parameters = { "integration.request.path.txid" = "'method.request.path.txid'" }
  type               = "MOCK"
}

resource "aws_api_gateway_method_response" "mockSantanderGetBillingResponse200" {
  rest_api_id = aws_api_gateway_rest_api.mockSantander.id
  resource_id = aws_api_gateway_resource.mockSantanderResourceTxId.id
  http_method = aws_api_gateway_method.mockSantanderGetBillingMethod.http_method
  status_code = "200"
  response_models = {
    "application/json" = aws_api_gateway_model.mockSantanderGetBillingResponseModel.name
  }
}

resource "aws_api_gateway_integration_response" "mockSantanderGetBillingIntegrationResponse200" {
  rest_api_id = aws_api_gateway_rest_api.mockSantander.id
  resource_id = aws_api_gateway_resource.mockSantanderResourceTxId.id
  http_method = aws_api_gateway_method.mockSantanderGetBillingMethod.http_method
  status_code = aws_api_gateway_method_response.mockSantanderGetBillingResponse200.status_code

  response_templates = {
    "application/json" = <<EOF
      {
      "status": "WAITING_PAYMENT",
      "txid": "$util.escapeJavaScript($input.params('txid'))",
      "calendario": {
        "criacao": "mockCriacao",
        "expiracao": "mockExpiracao"
      },
      "location": "mockLocation",
      "revisao": "mockRevisao",
      "valor": {
        "original": "mockValor"
      },
      "chave": "mockChave",
      "pix": [
        {
          "endToEndId": "mockEndToEndId",
          "txid": "$util.escapeJavaScript($input.params('txid'))",
          "valor": "mockValor",
          "horario": "mockHorario"
        }
      ],
      "devolucoes": [
        {
          "id": "mockId",
          "rtrId": "mockRtrId",
          "valor": "mockValor",
          "horario": {
            "solicitacao": "mockHorario",
            "liquidacao": "mockLiquidacao"
          },
          "status": "mockStatus"
        }
      ],
      "infoAdicionais": []
    }
    EOF
  }
}

resource "aws_api_gateway_method_response" "mockSantanderGetBillingResponse500" {
  rest_api_id = aws_api_gateway_rest_api.mockSantander.id
  resource_id = aws_api_gateway_resource.mockSantanderResourceTxId.id
  http_method = aws_api_gateway_method.mockSantanderGetBillingMethod.http_method
  status_code = "500"
  response_models = {
    "application/json" = aws_api_gateway_model.mockSantanderGetBillingResponseModel.name
  }
}

resource "aws_api_gateway_integration_response" "mockSantanderGetBillingIntegrationResponse500" {
  rest_api_id       = aws_api_gateway_rest_api.mockSantander.id
  resource_id       = aws_api_gateway_resource.mockSantanderResourceTxId.id
  http_method       = aws_api_gateway_method.mockSantanderGetBillingMethod.http_method
  status_code       = aws_api_gateway_method_response.mockSantanderGetBillingResponse500.status_code
  selection_pattern = "5\\d{2}"
}


resource "aws_api_gateway_method" "mockSantanderGetBillingMethod" {
  rest_api_id          = aws_api_gateway_rest_api.mockSantander.id
  resource_id          = aws_api_gateway_resource.mockSantanderResourceTxId.id
  http_method          = "GET"
  authorization        = "NONE"
  request_validator_id = aws_api_gateway_request_validator.mockSantanderGetBillingRequestValidator.id
  request_parameters   = { "method.request.path.txid" = true }
}
