# Define an IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })
}

# Define an IAM policy to grant Lambda permissions for EC2, CloudWatch, and SNS
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_execution_policy"
  description = "IAM policy for Lambda to stop EC2 instances"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:StopInstances",
          "cloudwatch:GetMetricStatistics",
          "sns:Publish"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = "logs:CreateLogGroup",
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:log-group:/aws/lambda/*"
      }
    ]
  })
}

# Attach the IAM policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Deploy the Lambda function
resource "aws_lambda_function" "stop_idle_ec2" {
  function_name = "StopIdleEC2Instances"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.8"
  handler       = "lambda.lambda_function.lambda_handler"
  filename      = "lambda_function.zip"

  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      SNS_TOPIC_ARN = "arn:aws:sns:us-east-1:717279705656:EC2ShutDownAlerts"
    }
  }
}

# Create a CloudWatch rule to trigger Lambda every 10 minutes
resource "aws_cloudwatch_event_rule" "every_10_minutes" {
  name                = "stop_idle_ec2_rule"
  schedule_expression = "rate(10 minutes)"
}

# Set the CloudWatch rule as a trigger for the Lambda function
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.every_10_minutes.name
  target_id = "lambda"
  arn       = aws_lambda_function.stop_idle_ec2.arn
}

# Grant CloudWatch permissions to invoke the Lambda function
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_idle_ec2.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_10_minutes.arn
}

# ----------------------------
# API Gateway Configuration
# ----------------------------

# Create an API Gateway REST API
resource "aws_api_gateway_rest_api" "lambda_api" {
  name        = "StopEC2API"
  description = "API Gateway to trigger Lambda"
}

# Create an API resource for the endpoint (/stop-instances)
resource "aws_api_gateway_resource" "stop_ec2" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  parent_id   = aws_api_gateway_rest_api.lambda_api.root_resource_id
  path_part   = "stop-instances"
}

# Define an HTTP POST method for the resource
resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.lambda_api.id
  resource_id   = aws_api_gateway_resource.stop_ec2.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integrate API Gateway with the Lambda function
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.lambda_api.id
  resource_id             = aws_api_gateway_resource.stop_ec2.id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.stop_idle_ec2.invoke_arn
}

# Deploy the API Gateway
resource "aws_api_gateway_deployment" "api_deploy" {
  depends_on  = [aws_api_gateway_integration.lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
}

# Create a stage 
resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.api_deploy.id
  rest_api_id   = aws_api_gateway_rest_api.lambda_api.id
  stage_name    = "prod"
}

# Grant API Gateway permissions to invoke the Lambda function
resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_idle_ec2.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.lambda_api.execution_arn}/*/*"
}
