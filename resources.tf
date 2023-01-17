resource "aws_api_gateway_rest_api" "mockSantander" {
  name        = "mockSantander"
  description = "Mock Santander made with TF"
}

resource "aws_api_gateway_resource" "mockSantanderResourceApi" {
  rest_api_id = aws_api_gateway_rest_api.mockSantander.id
  parent_id   = aws_api_gateway_rest_api.mockSantander.root_resource_id
  path_part   = "api"
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
