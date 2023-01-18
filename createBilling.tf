resource "aws_api_gateway_model" "mockSantanderCreateBillingRequestModel" {
  rest_api_id  = aws_api_gateway_rest_api.mockSantander.id
  name         = "CreateBillingRequestModel"
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

resource "aws_api_gateway_model" "mockSantanderCreateBillingResponseModel" {
  rest_api_id  = aws_api_gateway_rest_api.mockSantander.id
  name         = "CreateBillingResponseModel"
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
        "expiracao",
        "criacao"
      ]
    },
    "status": {
      "type": "string"
    },
    "txid": {
      "type": "string"
    },
    "revisao": {
      "type": "string"
    },
    "location": {
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
    }
  },
  "required": [
    "calendario",
    "status",
    "txid",
    "revisao",
    "location",
    "valor",
    "chave"
  ]
  }
  EOF
}

resource "aws_api_gateway_method" "mockSantanderCreateBillingMethod" {
  rest_api_id   = aws_api_gateway_rest_api.mockSantander.id
  resource_id   = aws_api_gateway_resource.mockSantanderResourceTxId.id
  http_method   = "PUT"
  authorization = "NONE"
  request_models = {
    "application/json" = aws_api_gateway_model.mockSantanderCreateBillingRequestModel.name
  }
}

resource "aws_api_gateway_integration" "mockSantanderCreateBillingIntegration" {
  rest_api_id = aws_api_gateway_rest_api.mockSantander.id
  resource_id = aws_api_gateway_resource.mockSantanderResourceTxId.id
  http_method = aws_api_gateway_method.mockSantanderCreateBillingMethod.http_method
  request_templates = {
    "application/json" = <<EOF
      {
        #if( $input.params('txid') == 123 )
          "statusCode": 200,
        #else
          "statusCode": 500,
        #end
        "body" : $util.escapeJavaScript($input.json('$'))
      }
    EOF
  }
  type = "MOCK"
}

resource "aws_api_gateway_integration_response" "mockSantanderCreateBillingIntegrationResponse200" {
  rest_api_id = aws_api_gateway_rest_api.mockSantander.id
  resource_id = aws_api_gateway_resource.mockSantanderResourceTxId.id
  http_method = aws_api_gateway_method.mockSantanderCreateBillingMethod.http_method
  status_code = aws_api_gateway_method_response.mockSantanderCreateBillingResponse200.status_code

  response_templates = {
    "application/json" = <<EOF
      #set($inputRoot = $input.path('$'))
      {
        "body": $inputRoot.id,
        "nada": $inputRoot.teste,
        "test": $inputRoot.test,
        "teste": $input.json('$'),
        "root": $inputRoot
      }
    EOF
  }
}

resource "aws_api_gateway_integration_response" "mockSantanderCreateBillingIntegrationResponse500" {
  rest_api_id       = aws_api_gateway_rest_api.mockSantander.id
  resource_id       = aws_api_gateway_resource.mockSantanderResourceTxId.id
  http_method       = aws_api_gateway_method.mockSantanderCreateBillingMethod.http_method
  status_code       = aws_api_gateway_method_response.mockSantanderCreateBillingResponse500.status_code
  selection_pattern = "5\\d{2}"

  response_templates = {
    "application/JSON" = <<EOF
      #set($inputRoot = $input.json('$'))
      {
        "body": $input.json('$.test'),
        "nada": $input.json('$.body')
        "test": $input.json('$.test')
      }
    EOF
  }
}

resource "aws_api_gateway_method_response" "mockSantanderCreateBillingResponse200" {
  rest_api_id = aws_api_gateway_rest_api.mockSantander.id
  resource_id = aws_api_gateway_resource.mockSantanderResourceTxId.id
  http_method = aws_api_gateway_method.mockSantanderCreateBillingMethod.http_method
  status_code = "200"
  response_models = {
    "application/json" = aws_api_gateway_model.mockSantanderCreateBillingResponseModel.name
  }
}

resource "aws_api_gateway_method_response" "mockSantanderCreateBillingResponse500" {
  rest_api_id = aws_api_gateway_rest_api.mockSantander.id
  resource_id = aws_api_gateway_resource.mockSantanderResourceTxId.id
  http_method = aws_api_gateway_method.mockSantanderCreateBillingMethod.http_method
  status_code = "500"
}
