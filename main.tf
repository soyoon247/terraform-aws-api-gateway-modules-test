resource "aws_api_gateway_resource" "resource" {
  rest_api_id = var.rest_api_id
  parent_id   = var.parent_id
  path_part   = var.path_part
}

module "_" {
  for_each = {
    for key, values in var.method_values : key => merge(var.common_values, values)
  }

  source                    = "./resources"
  path_part                 = var.path_part
  rest_api_id               = var.rest_api_id
  resource_id               = aws_api_gateway_resource.resource.id
  method_http_method        = each.key
  api_key_required          = lookup(each.value, "api_key_required", "false")
  authorization             = lookup(each.value, "authorization", "NONE")
  authorizer_id             = lookup(each.value, "authorizer_id", null)
  method_request_parameters = lookup(each.value, "method_request_parameters", null)
  method_operation_name     = lookup(each.value, "method_operation_name", null)
  method_request_models     = lookup(each.value, "method_request_models", null)
  method_response_map       = lookup(each.value, "method_response_map", null)

  integration_cache_key_parameters = lookup(each.value, "integration_cache_key_parameters", null)
  integration_request_parameters   = lookup(each.value, "integration_request_parameters", null)
  integration_connection_type      = lookup(each.value, "integration_connection_type", "INTERNET")
  integration_http_method          = lookup(each.value, "integration_http_method", null)
  integration_passthrough_behavior = lookup(each.value, "integration_passthrough_behavior", "WHEN_NO_MATCH")
  integration_timeout_milliseconds = lookup(each.value, "integration_timeout_milliseconds", 29000)
  integration_type                 = lookup(each.value, "integration_type", null)
  integration_uri                  = lookup(each.value, "integration_uri", null)
  integration_request_templates    = lookup(each.value, "integration_request_templates", null)
  integration_response_map         = lookup(each.value, "integration_response_map", null)
  depends_on                       = [aws_api_gateway_resource.resource]
}
