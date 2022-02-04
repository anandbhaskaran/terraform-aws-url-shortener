resource "aws_api_gateway_integration_response" "integration_response_400" {
  rest_api_id       = var.api_gateway_id
  resource_id       = var.resource_id
  http_method       = var.http_method
  status_code       = aws_api_gateway_method_response.response_400.status_code
  selection_pattern = "4\\d{2}"
}

resource "aws_api_gateway_integration_response" "integration_response_500" {
  rest_api_id       = var.api_gateway_id
  resource_id       = var.resource_id
  http_method       = var.http_method
  status_code       = aws_api_gateway_method_response.response_500.status_code
  selection_pattern = "5\\d{2}"
}

resource "aws_api_gateway_method_response" "response_400" {
  rest_api_id = var.api_gateway_id
  resource_id = var.resource_id
  http_method = var.http_method
  status_code = "400"
}

resource "aws_api_gateway_method_response" "response_500" {
  rest_api_id = var.api_gateway_id
  resource_id = var.resource_id
  http_method = var.http_method
  status_code = "500"
}