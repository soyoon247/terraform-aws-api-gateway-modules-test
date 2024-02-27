variable "rest_api_id" {
  type        = string
  description = "aws_api_gateway_rest_api의 ID"
}

variable "path_part" {
  type        = string
  description = "aws_api_gateway_resource의 path_part"
}


variable "resource_id" {
  type        = string
  description = "aws_api_gateway_resource의 ID"
}


# aws_api_gateway_method에서 사용되는 변수들
variable "method_http_method" {
  type        = string
  description = "aws_api_gateway_method의 HTTP method (GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY)"
}

variable "api_key_required" {
  type        = bool
  description = "aws_api_gateway_method가 ApiKey를 필요로 하는지 여부"
}

variable "authorization" {
  type        = string
  description = "aws_api_gateway_method의 authorization type. (NONE, AWS_IAM, CUSTOM, COGNITO_USER_POOLS)"
}

variable "authorizer_id" {
  type        = string
  description = "aws_api_gateway_method가 사용하는 custom authorizer의 ID"
}

variable "method_request_parameters" {
  type        = map(string)
  description = "aws_api_gateway_method의 request parameters (paths, query strings and headers) 정보를 나타내는 map"
}

variable "method_operation_name" {
  type        = string
  description = "aws_api_gateway_method의 operation_name"
}

variable "method_request_models" {
  type        = map(string)
  description = "aws_api_gateway_method의 request_models"
}

# aws_api_gateway_method_response에서 사용되는 변수들
variable "method_response_map" {
  type = map(
    object({
      response_parameters = optional(map(string))
      response_models     = optional(map(string))
    })
  )
  description = "aws_api_gateway_method_response의 status_code별 response parameters, response_models 정보를 나타내는 map"
}

# aws_api_gateway_integration에서 사용되는 변수들
variable "integration_cache_key_parameters" {
  type        = list(string)
  description = "aws_api_gateway_integration의 integration_cache_key_parameters (method.request.path.proxy, method.request.querystring.proxy 등)"
}

variable "integration_request_parameters" {
  type        = map(string)
  description = "aws_api_gateway_integration의 request_paremeters 정보를 나타내는 map"
}

variable "integration_connection_type" {
  type        = string
  description = "aws_api_gateway_integration의 connection_type (INTERNET, VPC_LINK)"
}

variable "integration_http_method" {
  type        = string
  description = "aws_api_gateway_integration의 HTTP method (GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY)"
}

variable "integration_passthrough_behavior" {
  type        = string
  description = "aws_api_gateway_integration의 passthrough_behavior (WHEN_NO_MATCH, WHEN_NO_TEMPLATES, NEVER)"
}

variable "integration_timeout_milliseconds" {
  type        = number
  description = "aws_api_gateway_integration의 timeout_milliseconds (50 ~ 29000)"
}

variable "integration_type" {
  type        = string
  description = "aws_api_gateway_integration의 type (AWS, AWS_PROXY, HTTP, HTTP_PROXY, MOCK)"
}

variable "integration_uri" {
  type        = string
  description = "aws_api_gateway_integration의 uri"
}


variable "integration_request_templates" {
  type        = map(string)
  description = "aws_api_gateway_integration의 request_templates"
}

# aws_api_gateway_integration_response에서 사용되는 변수들
variable "integration_response_map" {
  type = map(object({
    response_parameters = optional(map(string))
    selection_pattern   = optional(string)
    response_templates  = optional(map(string))
  }))
  description = "aws_api_gateway_integration_response의 status_code별 response_templates, response parameters, selection_pattern 정보를 나타내는 map"
}
