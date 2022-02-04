# creating a regional rest API
resource "aws_api_gateway_rest_api" "url_shortner" {
  name        = var.api_gateway_name
  description = "Url shortener rest API"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

#------------------------------------------------
# Method to add new item into the database
#-------------------------------------------------

# first resource shorten to add data into database
resource "aws_api_gateway_resource" "short" {
  rest_api_id = aws_api_gateway_rest_api.url_shortner.id
  parent_id   = aws_api_gateway_rest_api.url_shortner.root_resource_id
  path_part   = "short"
}

# post method in shorten resource
resource "aws_api_gateway_method" "short_post" {
  rest_api_id   = aws_api_gateway_rest_api.url_shortner.id
  resource_id   = aws_api_gateway_resource.short.id
  http_method   = "POST"
  authorization = "NONE"
}

#  integration request in post method in app resource
resource "aws_api_gateway_integration" "short_post_ireq" {
  rest_api_id             = aws_api_gateway_rest_api.url_shortner.id
  resource_id             = aws_api_gateway_resource.short.id
  http_method             = aws_api_gateway_method.short_post.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:eu-west-1:dynamodb:action/UpdateItem"

  credentials = aws_iam_role.write_dynamo_role.arn

  passthrough_behavior = "WHEN_NO_TEMPLATES"

  request_templates = {
    "application/json" = <<EOF
    {
      "TableName": "short-url",
      "ConditionExpression": "attribute_not_exists(slug)",
      "Key": {
        "slug": {
          "S": $input.json('$.slug')
        }
      },
      "ExpressionAttributeNames": {
        "#u": "long_url",
        "#ts": "timestamp"
      },
      "ExpressionAttributeValues": {
        ":u": {
          "S": $input.json('$.long_url')
        },
        ":ts": {
          "S": "$context.requestTime"
        }
      },
      "UpdateExpression": "SET #u = :u, #ts = :ts",
      "ReturnValues": "ALL_NEW"
    }
EOF
  }
}

#  method response code for post method in app resource
resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.url_shortner.id
  resource_id = aws_api_gateway_resource.short.id
  http_method = aws_api_gateway_method.short_post.http_method
  status_code = "200"
}

# integration response for post method in app resource
resource "aws_api_gateway_integration_response" "short_post-ires" {
  rest_api_id = aws_api_gateway_rest_api.url_shortner.id
  resource_id = aws_api_gateway_resource.short.id
  http_method = aws_api_gateway_method.short_post.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  selection_pattern = "200"
  response_templates = {
    "application/json" = <<EOF
    #set($inputRoot = $input.path('$'))
    {
      "slug": "$inputRoot.Attributes.slug.S",
      "long_url": "$inputRoot.Attributes.long_url.S",
      "timestamp": "$inputRoot.Attributes.timestamp.S",
    }
EOF
  }
}

module "error-responses-positions" {
  source = "./error-responses"
  api_gateway_id = aws_api_gateway_rest_api.url_shortner.id
  resource_id = aws_api_gateway_resource.short.id
  http_method = aws_api_gateway_method.short_post.http_method
}

#------------------------------------------------
# Method {slug} for querying short URL from the database
#-------------------------------------------------

# id resource
resource "aws_api_gateway_resource" "slug" {
  rest_api_id = aws_api_gateway_rest_api.url_shortner.id
  parent_id   = aws_api_gateway_rest_api.url_shortner.root_resource_id
  path_part   = "{slug}"
}

# using get http method here so that we can query the database form browser
resource "aws_api_gateway_method" "slug-post" {
  rest_api_id   = aws_api_gateway_rest_api.url_shortner.id
  resource_id   = aws_api_gateway_resource.slug.id
  http_method   = "GET"
  authorization = "NONE"
}

# integration request to accept key in header
resource "aws_api_gateway_integration" "slug-post-ireq" {
  rest_api_id             = aws_api_gateway_rest_api.url_shortner.id
  resource_id             = aws_api_gateway_resource.slug.id
  http_method             = aws_api_gateway_method.slug-post.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:eu-west-1:dynamodb:action/GetItem"

  credentials = aws_iam_role.read_dynamo_role.arn

  passthrough_behavior = "WHEN_NO_TEMPLATES"

  request_templates = {
    "application/json" = <<EOF
        {
  "Key": {
    "slug": {
      "S": "$util.escapeJavaScript($input.params().path.slug)"
    }
  },
  "TableName": "short-url"
}

EOF
  }
}

# Using 301 response here so that it will directtly redirect the user to location
resource "aws_api_gateway_method_response" "response_301" {
  rest_api_id         = aws_api_gateway_rest_api.url_shortner.id
  resource_id         = aws_api_gateway_resource.slug.id
  http_method         = aws_api_gateway_method.slug-post.http_method
  status_code         = "301"
  response_parameters = { "method.response.header.Location" = true }
}

# integration response for query
resource "aws_api_gateway_integration_response" "slug-post-ires" {
  rest_api_id = aws_api_gateway_rest_api.url_shortner.id
  resource_id = aws_api_gateway_resource.slug.id
  http_method = aws_api_gateway_method.slug-post.http_method
  status_code = aws_api_gateway_method_response.response_301.status_code

  selection_pattern = "200"
  response_templates = {
    "application/json" = <<EOF
    #set($inputRoot = $input.path('$'))
#if ($inputRoot.toString().contains("Item"))
  #set($context.responseOverride.header.Location = $inputRoot.Item.long_url.S)
#end
EOF
  }
}

# deplyoing the API to prod stage
resource "aws_api_gateway_deployment" "prod-api" {
  depends_on = [aws_api_gateway_integration.slug-post-ireq]

  rest_api_id = aws_api_gateway_rest_api.url_shortner.id
  stage_name  = var.api_gateway_stage_name
}
