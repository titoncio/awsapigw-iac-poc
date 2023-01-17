resource "aws_api_gateway_method" "mockSantanderGetBillingMethod" {
  rest_api_id   = aws_api_gateway_rest_api.mockSantander.id
  resource_id   = aws_api_gateway_resource.mockSantanderResourceTxId.id
  http_method   = "GET"
  authorization = "NONE"
}
