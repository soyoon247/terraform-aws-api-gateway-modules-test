locals {
  # constants
  empty_method_response_map = tomap({})

  empty_response_models = {
    "application/json" = "Empty"
  }

  status_200_request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }

  default_method_response_map = tomap({
    200 = {
      response_models     = {}
      response_parameters = {}
    }
  })

  default_integration_response_map = tomap({
    200 = {
      response_parameters = {}
      selection_pattern   = null
      response_templates  = {}
    }
  })

  x_forwarded_for_method_request_parameters = {
    "method.request.header.X-Forwarded-For" = "false"
  }

  x_forwarded_for_integration_request_parameters = {
    "integration.request.header.X-Forwarded-For" = "method.request.header.X-Forwarded-For"
  }

  proxy_method_request_parameters = {
    "method.request.path.proxy" = true
  }

  proxy_method_response_map = local.empty_method_response_map

  proxy_integration_cache_key_parameters = ["method.request.path.proxy"]

  proxy_integration_request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }

  options_method_response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "false"
    "method.response.header.Access-Control-Allow-Methods" = "false"
    "method.response.header.Access-Control-Allow-Origin"  = "false"
  }

  options_method_response_map = tomap({
    200 = {
      response_models     = local.empty_response_models
      response_parameters = local.options_method_response_parameters
    }
  })

  options_integration_request_templates = local.status_200_request_templates

  # variable 에 따라 값이 달라지는 부분
  is_options_method         = var.method_http_method == "OPTIONS"
  integration_type          = local.is_options_method ? "MOCK" : var.integration_type
  is_proxy_type             = local.integration_type == "HTTP_PROXY"
  is_mock_type              = local.integration_type == "MOCK"
  is_http_proxy_integration = (local.is_proxy_type && var.path_part == "{proxy+}")

  _method_request_parameters_when_not_mock_type = (
    var.method_request_parameters == null && local.is_http_proxy_integration ?
    local.proxy_method_request_parameters :
    var.method_request_parameters
  )

  method_request_parameters = (
    local.is_mock_type ?
    var.method_request_parameters :
    (
      local.is_proxy_type ?
      local._method_request_parameters_when_not_mock_type :
      merge(local._method_request_parameters_when_not_mock_type, local.x_forwarded_for_method_request_parameters)
    )
  )

  method_response_map = (
    var.method_response_map != null ?
    var.method_response_map :
    (
      local.is_options_method ?
      local.options_method_response_map :
      (
        local.is_http_proxy_integration ?
        local.proxy_method_response_map :
        local.default_method_response_map
      )
    )
  )

  integration_cache_key_parameters = (
    var.integration_cache_key_parameters != null ?
    var.integration_cache_key_parameters :
    (
      local.is_http_proxy_integration ?
      local.proxy_integration_cache_key_parameters :
      null
    )
  )

  _integration_request_parameters_when_not_mock_type = (
    var.integration_request_parameters == null && local.is_http_proxy_integration ?
    local.proxy_integration_request_parameters :
    var.integration_request_parameters
  )

  integration_request_parameters = (
    local.is_mock_type ?
    var.integration_request_parameters :
    (
        local.is_proxy_type ?
        local._integration_request_parameters_when_not_mock_type :
        merge(local._integration_request_parameters_when_not_mock_type, local.x_forwarded_for_integration_request_parameters)
    )
  )

  integration_http_method = (
    var.integration_http_method != null ?
    var.integration_http_method :
    (
      local.integration_type == "MOCK" ?
      null :
      var.method_http_method
    )
  )

  integration_request_templates = (
    var.integration_request_templates != null ?
    var.integration_request_templates :
    (
      local.is_options_method ?
      local.options_integration_request_templates :
      var.integration_request_templates
    )
  )

  integration_response_map = (
    var.integration_response_map != null ?
    var.integration_response_map :
    local.default_integration_response_map
  )
}
