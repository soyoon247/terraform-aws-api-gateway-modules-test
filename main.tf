resource "aws_api_gateway_resource" "resource" {
  rest_api_id = var.rest_api_id
  parent_id   = var.parent_id
  path_part   = var.path_part
}

locals {
  get_values = merge(lookup(var.method_values, "GET", {}), var.common_values)
  get = {
    method_http_method               = lookup(get_values, "method_http_method", null)
    api_key_required                 = lookup(get_values, "api_key_required", "false")
    authorization                    = lookup(get_values, "authorization", "NONE")
    authorizer_id                    = lookup(get_values, "authorizer_id", null)
    method_request_parameters        = lookup(get_values, "method_request_parameters", null)
    method_operation_name            = lookup(get_values, "method_operation_name", null)
    method_request_models            = lookup(get_values, "method_request_models", null)
    method_response_map              = lookup(get_values, "method_response_map", null)
    integration_cache_key_parameters = lookup(get_values, "integration_cache_key_parameters", null)
    integration_request_parameters   = lookup(get_values, "integration_request_parameters", null)
    integration_connection_type      = lookup(get_values, "integration_connection_type", "INTERNET")
    integration_http_method          = lookup(get_values, "integration_http_method", null)
    integration_passthrough_behavior = lookup(get_values, "integration_passthrough_behavior", "WHEN_NO_MATCH")
    integration_timeout_milliseconds = lookup(get_values, "integration_timeout_milliseconds", 29000)
    integration_type                 = lookup(get_values, "integration_type", "HTTP_PROXY")
    integration_uri                  = lookup(get_values, "integration_uri", null)
    integration_request_templates    = lookup(get_values, "integration_request_templates", null)
    integration_response_map         = lookup(get_values, "integration_response_map", null)

    is_options_method         = false
    is_proxy_type             = local.get.integration_type == "HTTP_PROXY"
    is_mock_type              = local.get.integration_type == "MOCK"
    is_http_proxy_integration = (local.get.is_proxy_type && var.path_part == "{proxy+}")

    _method_request_parameters_when_not_mock_type = (
      local.get.method_request_parameters == null && local.get.is_http_proxy_integration ?
      local.proxy_method_request_parameters :
      local.get.method_request_parameters
    )

    method_request_parameters = (
      local.get.is_mock_type ?
      local.get.method_request_parameters :
      (
        local.get.is_proxy_type ?
        local.get._method_request_parameters_when_not_mock_type :
        merge(local.get._method_request_parameters_when_not_mock_type, local.x_forwarded_for_method_request_parameters)
      )
    )

    _method_response_map = (
      local.get.method_response_map != null ?
      local.get.method_response_map :
      (
        local.get.is_options_method ?
        local.options_method_response_map :
        (
          local.get.is_http_proxy_integration ?
          local.proxy_method_response_map :
          local.default_method_response_map
        )
      )
    )

    integration_cache_key_parameters = (
      local.get.integration_cache_key_parameters != null ?
      local.get.integration_cache_key_parameters :
      (
        local.get.is_http_proxy_integration ?
        local.proxy_integration_cache_key_parameters :
        null
      )
    )

    _integration_request_parameters_when_not_mock_type = (
      local.get.integration_request_parameters == null && local.get.is_http_proxy_integration ?
      local.proxy_integration_request_parameters :
      local.get.integration_request_parameters
    )

    integration_request_parameters = (
      local.get.is_mock_type ?
      local.get.integration_request_parameters :
      (
        local.get.is_proxy_type ?
        local.get._integration_request_parameters_when_not_mock_type :
        merge(local.get._integration_request_parameters_when_not_mock_type, local.x_forwarded_for_integration_request_parameters)
      )
    )

    integration_http_method = (
      local.get.integration_http_method != null ?
      local.get.integration_http_method :
      (
        local.get.integration_type == "MOCK" ?
        null :
        local.get.method_http_method
      )
    )

    integration_request_templates = (
      local.get.integration_request_templates != null ?
      local.get.integration_request_templates :
      (
        local.get.is_options_method ?
        local.options_integration_request_templates :
        local.get.integration_request_templates
      )
    )

    _integration_response_map = (
      local.get.integration_response_map != null ?
      local.get.integration_response_map :
      local.default_integration_response_map
    )


    method_response_map = {
      for key, value in local.get.method_response_map : key => merge(value, { "http_method" = local.get.method_http_method })
    }
    integration_response_map = {
      for key, value in local.get.integration_response_map : key => merge(value, { "http_method" = local.get.method_http_method })
    }

  }

  value_map = {
    "GET" = local.get
  }

  integration_response_map_list = flatten(
    local.get.integration_response_map
  )

  method_response_map_list = flatten(
    local.get.method_response_map
  )
}

resource "aws_api_gateway_method" "method" {
  for_each           = local.value_map
  rest_api_id        = var.rest_api_id
  resource_id        = aws_api_gateway_resource.resource.id
  api_key_required   = lookup(each.value, "api_key_required", null)
  authorization      = lookup(each.value, "authorization", null)
  authorizer_id      = lookup(each.value, "authorizer_id", null)
  http_method        = lookup(each.value, "method_http_method", null)
  request_parameters = lookup(each.value, "method_request_parameters", null)
  request_models     = lookup(each.value, "method_request_models", null)
  operation_name     = lookup(each.value, "method_operation_name", null)
  depends_on         = [aws_api_gateway_resource.resource]
}

resource "aws_api_gateway_integration" "integration" {
  for_each = local.value_map

  rest_api_id             = var.rest_api_id
  resource_id             = aws_api_gateway_resource.resource.id
  cache_namespace         = aws_api_gateway_resource.resource.id
  cache_key_parameters    = lookup(each.value, "integration_cache_key_parameters", null)
  connection_type         = lookup(each.value, "integration_connection_type", null)
  http_method             = lookup(each.value, "method_http_method", null)
  integration_http_method = lookup(each.value, "integration_http_method", null)
  passthrough_behavior    = lookup(each.value, "integration_passthrough_behavior", null)
  timeout_milliseconds    = lookup(each.value, "integration_timeout_milliseconds", null)
  type                    = lookup(each.value, "integration_type", null)
  uri                     = lookup(each.value, "integration_uri", null)
  request_parameters      = lookup(each.value, "integration_request_parameters", null)
  request_templates       = lookup(each.value, "integration_request_templates", null)
  depends_on              = [aws_api_gateway_resource.resource, aws_api_gateway_method.method]
}

resource "aws_api_gateway_method_response" "method_response" {
  for_each            = local.method_response_map_list
  rest_api_id         = var.rest_api_id
  resource_id         = aws_api_gateway_resource.resource.id
  http_method         = lookup(each.value, "method_http_method", null)
  response_parameters = lookup(each.value, "response_parameters", null)
  response_models     = lookup(each.value, "response_models", null)
  status_code         = each.key
  depends_on          = [aws_api_gateway_resource.resource, aws_api_gateway_method.method]
}



resource "aws_api_gateway_integration_response" "integration_response" {
  for_each            = local.integration_response_map_list
  rest_api_id         = var.rest_api_id
  resource_id         = aws_api_gateway_resource.resource.id
  http_method         = lookup(each.value, "method_http_method", null)
  response_parameters = lookup(each.value, "response_parameters", null)
  status_code         = each.key
  selection_pattern   = lookup(each.value, "selection_pattern", null)
  response_templates  = lookup(each.value, "response_templates", null)
  depends_on          = [aws_api_gateway_resource.resource, aws_api_gateway_integration.integration]
}



#
#module "_" {
#  for_each = {
#    for key, values in var.method_values : key => merge(var.common_values, values)
#  }
#
#  source                    = "./resources"
#  path_part                 = var.path_part
#  rest_api_id               = var.rest_api_id
#  resource_id               = aws_api_gateway_resource.resource.id
#  method_http_method        = each.key
#  api_key_required          = lookup(each.value, "api_key_required", "false")
#  authorization             = lookup(each.value, "authorization", "NONE")
#  authorizer_id             = lookup(each.value, "authorizer_id", null)
#  method_request_parameters = lookup(each.value, "method_request_parameters", null)
#  method_operation_name     = lookup(each.value, "method_operation_name", null)
#  method_request_models     = lookup(each.value, "method_request_models", null)
#  method_response_map       = lookup(each.value, "method_response_map", null)
#
#  integration_cache_key_parameters = lookup(each.value, "integration_cache_key_parameters", null)
#  integration_request_parameters   = lookup(each.value, "integration_request_parameters", null)
#  integration_connection_type      = lookup(each.value, "integration_connection_type", "INTERNET")
#  integration_http_method          = lookup(each.value, "integration_http_method", null)
#  integration_passthrough_behavior = lookup(each.value, "integration_passthrough_behavior", "WHEN_NO_MATCH")
#  integration_timeout_milliseconds = lookup(each.value, "integration_timeout_milliseconds", 29000)
#  integration_type                 = lookup(each.value, "integration_type", null)
#  integration_uri                  = lookup(each.value, "integration_uri", null)
#  integration_request_templates    = lookup(each.value, "integration_request_templates", null)
#  integration_response_map         = lookup(each.value, "integration_response_map", null)
#  depends_on                       = [aws_api_gateway_resource.resource]
#}
