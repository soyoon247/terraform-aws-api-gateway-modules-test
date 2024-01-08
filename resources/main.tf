resource "aws_api_gateway_method" "method" {
  rest_api_id        = var.rest_api_id
  resource_id        = var.resource_id
  api_key_required   = var.api_key_required
  authorization      = var.authorization
  authorizer_id      = var.authorizer_id
  http_method        = var.method_http_method
  request_parameters = local.method_request_parameters
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = var.rest_api_id
  resource_id             = var.resource_id
  cache_namespace         = var.resource_id
  cache_key_parameters    = local.integration_cache_key_parameters
  connection_type         = var.integration_connection_type
  http_method             = var.method_http_method
  integration_http_method = local.integration_http_method
  passthrough_behavior    = var.integration_passthrough_behavior
  timeout_milliseconds    = var.integration_timeout_milliseconds
  type                    = local.integration_type
  uri                     = var.integration_uri
  request_parameters      = local.integration_request_parameters
  request_templates       = local.integration_request_templates
  depends_on              = [aws_api_gateway_method.method]
}

resource "aws_api_gateway_method_response" "method_response" {
  for_each            = local.method_response_map
  rest_api_id         = var.rest_api_id
  resource_id         = var.resource_id
  http_method         = var.method_http_method
  response_parameters = each.value["response_parameters"]
  response_models     = each.value["response_models"]
  status_code         = each.key
  depends_on          = [aws_api_gateway_method.method, aws_api_gateway_integration.integration]
}



resource "aws_api_gateway_integration_response" "integration_response" {
  for_each            = local.integration_response_map
  rest_api_id         = var.rest_api_id
  resource_id         = var.resource_id
  http_method         = var.method_http_method
  response_parameters = each.value["response_parameters"]
  status_code         = each.key
  selection_pattern   = each.value["selection_pattern"]
  depends_on          = [aws_api_gateway_method_response.method_response, aws_api_gateway_integration.integration]
}
