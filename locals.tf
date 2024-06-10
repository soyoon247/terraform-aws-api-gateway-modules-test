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
}
