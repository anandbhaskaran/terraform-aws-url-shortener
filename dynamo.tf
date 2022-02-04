# Dynamodb table with config cover in free trial
# if you want you can increase thhe read write capacity FYI it will add costs
resource "aws_dynamodb_table" "default" {
  name           = var.dynamo_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "slug"
  attribute {
    name = "slug"
    type = "S"
  }
}