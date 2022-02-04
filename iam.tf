// Write Role for API to write new data into dynamodb table
resource "aws_iam_role" "write_dynamo_role" {
  name               = "dynamo-url-short-write_dynamo_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "write_iam_instance_profile" {
  name = "write_iam_instance_profile"
  role = aws_iam_role.write_dynamo_role.name
}

#  inline policy for write role
resource "aws_iam_role_policy" "write_dynamo_policy" {
  name = "write_dynamo_policy"
  role = aws_iam_role.write_dynamo_role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:UpdateItem"
        ],
        "Resource" : "*"
      }
    ]
  })
}

// Read Role for API to read data from dynamodb table
resource "aws_iam_role" "read_dynamo_role" {
  name               = "url_short_read_dynamo_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "read_iam_instance_profile" {
  name = "read_iam_instance_profile"
  role = aws_iam_role.read_dynamo_role.name
}

# inline policy for read role 
resource "aws_iam_role_policy" "read_dynamo_policy" {
  name = "read_dynamo_policy"
  role = aws_iam_role.read_dynamo_role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:BatchGetItem",
          "dynamodb:GetItem",
          "dynamodb:Query"
        ],
        "Resource" : "*"
      }
    ]
  })
}
