variable "rest_api_id" {
  type        = string
  description = "aws_api_gateway_rest_api의 ID"
}

variable "parent_id" {
  type        = string
  description = "aws_api_gateway_resource의 부모 resource의 ID"
}

variable "path_part" {
  type        = string
  description = "aws_api_gateway_resource의 path_part"
}

variable "method_values" {
  type        = any
  description = "method별로 aws_api_gateway_method, aws_api_gateway_method_response, aws_api_gateway_integration, aws_api_gateway_interation_response의 attribute를 나타내는 map"
  default     = {}
}

variable "common_values" {
  type        = any
  description = "method가 공통으로 갖는 aws_api_gateway_method, aws_api_gateway_method_response, aws_api_gateway_integration, aws_api_gateway_interation_response의 attribute를 나타내는 map"
  default     = {}
}
