variable "api_gateway_name" {
  type = string
  description = "Name of the API gateway"
  default = "url-shortner"
}

variable "api_gateway_stage_name" {
  type = string
  description = "Stage name of the API gateway"
  default = "master"
}

variable "dynamo_table_name" {
  type = string
  description = "Name of the DynamoDB table. You should also change the mapping templates if you need to change it"
  default = "short-url"
}