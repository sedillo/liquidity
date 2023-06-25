data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "rpp-lambda"
  output_path = "rpp-payload.zip"
}

resource "aws_lambda_function" "rpp_lambda" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "example_lambda"
  role          = aws_iam_role.vpc_for_lambda.arn
  handler       = "rpp-lambda.lambda_handler"

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  vpc_config {
    # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
    subnet_ids         = aws_subnet.main[*].id
    security_group_ids = [aws_vpc.main.default_security_group_id]
  }

  runtime = "python3.10"

  environment {
    variables = {
      DB_HOST     = aws_db_instance.default.endpoint
      DB_USER     = aws_db_instance.default.username
      DB_PASSWORD = data.aws_secretsmanager_secret_version.db_password.secret_string
      DB_NAME     = aws_db_instance.default.db_name
    }
  }
}

resource "aws_iam_role" "vpc_for_lambda" {
  name = "vpc_For_lambda"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {"Service": ["lambda.amazonaws.com", "ec2.amazonaws.com"]},
            "Action": "sts:AssumeRole"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "vpc_lambda_policy" {
  role       = aws_iam_role.vpc_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rpp_lambda.function_name
  principal     = "events.amazonaws.com"
}

