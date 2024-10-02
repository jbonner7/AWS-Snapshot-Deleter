provider "aws" {
  region = "ca-central-1" # Adjust based on your region
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_snapshot_cleaner_role" {
  name = "lambda_snapshot_cleaner_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# IAM Policy for Lambda to manage EC2 snapshots
resource "aws_iam_policy" "lambda_snapshot_cleaner_policy" {
  name        = "lambda_snapshot_cleaner_policy"
  description = "Policy to allow Lambda to delete EC2 snapshots older than 7 days"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeSnapshots",
        "ec2:DeleteSnapshot",
        "ec2:DescribeTags"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Attach the policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_snapshot_cleaner_attachment" {
  role       = aws_iam_role.lambda_snapshot_cleaner_role.name
  policy_arn = aws_iam_policy.lambda_snapshot_cleaner_policy.arn
}

# Lambda Function
resource "aws_lambda_function" "snapshot_cleaner_lambda" {
  function_name = "snapshot_cleaner"
  role          = aws_iam_role.lambda_snapshot_cleaner_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  
  # Path to the ZIP package containing your Lambda code
  filename      = "lambda_function_payload.zip"

  source_code_hash = filebase64sha256("lambda_function_payload.zip")

  # Set Lambda timeout to 20 seconds
  timeout       = 20

}

# CloudWatch EventBridge Rule (Schedule for daily trigger)
resource "aws_cloudwatch_event_rule" "snapshot_cleanup_rule" {
  name        = "snapshot_cleanup_rule"
  description = "Daily trigger to clean up EC2 snapshots older than 7 days"
  schedule_expression = "cron(0 0 * * ? *)"  # Every day at midnight UTC
}

# Lambda Target for the EventBridge Rule
resource "aws_cloudwatch_event_target" "snapshot_cleanup_target" {
  rule      = aws_cloudwatch_event_rule.snapshot_cleanup_rule.name
  target_id = "snapshot_cleanup_lambda"
  arn       = aws_lambda_function.snapshot_cleaner_lambda.arn
}

# Grant permissions for EventBridge to invoke Lambda
resource "aws_lambda_permission" "allow_eventbridge_to_invoke_lambda" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.snapshot_cleaner_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.snapshot_cleanup_rule.arn
}
