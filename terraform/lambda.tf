data "archive_file" "invalidate" {
  type = "zip"

  source_dir  = "${path.module}/invalidate"
  output_path = "${path.module}/invalidate.zip"
}

data "aws_iam_policy_document" "invalidate_policy" {
  statement {
    effect = "Allow"
    actions = [
      "codepipeline:PutJobFailureResult",
      "codepipeline:PutJobSuccessResult",
      "cloudfront:CreateInvalidation"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "invalidate_role" {
  name               = "invalidate_role"
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

resource "aws_iam_policy" "invalidate_managed_policy" {
  name        = "invalidate_managed_policy"
  description = "Managed policy for Lambda function to invalidate CloudFront cache"
  policy      = data.aws_iam_policy_document.invalidate_policy.json
}

resource "aws_iam_role_policy_attachment" "invalidate_policy_attachment" {
  role       = aws_iam_role.invalidate_role.name
  policy_arn = aws_iam_policy.invalidate_managed_policy.arn
}

resource "aws_lambda_function" "invalidate_lambda" {
  filename      = "lambda_function_payload.zip"
  function_name = "invalidate_lambda"
  role          = aws_iam_role.invalidate_role.arn
  handler       = "lambda_handler"
  runtime       = "python3.11"

  environment {
    variables = {
      DISTRIBUTION_ID = var.distribution
    }
  }
}