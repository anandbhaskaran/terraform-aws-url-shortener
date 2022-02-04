variable "api_gateway_id" {
  type = string
  description = "Id of the API gateways the endpoint belongs to"
}

variable "resource_id" {
  type = string
  description = "Id of the API resource pointing to API version"
}

variable "http_method" {
  type = string
  description = "Type of method the response should be attached to"
}