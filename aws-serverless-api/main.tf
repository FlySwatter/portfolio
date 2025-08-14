terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.project}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "basic_exec" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_dynamodb_table" "todos" {
  name         = "${var.project}-todos"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute { name = "id"; type = "S" }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_payload.zip"
}

resource "aws_lambda_function" "api" {
  function_name = "${var.project}-handler"
  role          = aws_iam_role.lambda_role.arn
  filename      = data.archive_file.lambda_zip.output_path
  handler       = "lambda_function.handler"
  runtime       = "python3.11"
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.todos.name
    }
  }
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.project}-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.api.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "post_todos" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /todos"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_route" "get_todo" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /todos/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

output "api_invoke_url" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}
