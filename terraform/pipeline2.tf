data "aws_iam_policy_document" "codebuild" {
  statement {
    effect = "Allow"

    resources = [
      "arn:aws:logs:us-east-1:233907574649:log-group:/aws/codebuild/ardac-website",
      "arn:aws:logs:us-east-1:233907574649:log-group:/aws/codebuild/ardac-website:*"
    ]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
  }

  statement {
    effect = "Allow"

    resources = [
      "arn:aws:s3:::codepipeline-us-east-1-*"
    ]

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]
  }

  statement {
    effect = "Allow"

    resources = [
      "arn:aws:codebuild:us-east-1:233907574649:report-group/ardac-website-*"
    ]

    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
      "codebuild:BatchPutCodeCoverages"
    ]
  }
}

resource "aws_iam_policy" "codebuild" {
  name        = "CodeBuildBasePolicy-ardac-website-us-east-1"
  description = "An example policy"
  policy      = data.aws_iam_policy_document.codebuild.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codebuild_ardac_website_service_role" {
  name               = "codebuild-ardac-website-service-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "codebuild_policy_attach" {
  role       = aws_iam_role.codebuild_ardac_website_service_role.name
  policy_arn = aws_iam_policy.codebuild.arn
}

resource "aws_codebuild_project" "ardac_website" {
  name           = "ardac-website"
  description    = "Deploy ardac.org website to S3."
  service_role   = "arn:aws:iam::233907574649:role/service-role/codebuild-ardac-website-service-role"
  build_timeout  = "15"
  queued_timeout = "480"

  artifacts {
    type = "CODEPIPELINE"
    name = "ardac-website"
  }

  environment {
    compute_type                = "BUILD_LAMBDA_2GB"
    image                       = "aws/codebuild/amazonlinux-aarch64-lambda-standard:python3.12"
    type                        = "ARM_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = <<EOF
version: 0.2

artifacts:
  base-directory: 'src'
  files:
    - '**/*'
EOF
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      status = "DISABLED"
    }
  }
}

resource "aws_codepipeline" "codepipeline" {
  name     = "ardac-website-deployment"
  role_arn = "arn:aws:iam::233907574649:role/service-role/AWSCodePipelineServiceRole-us-east-1-ardac-website-deployment"

  artifact_store {
    location = "codepipeline-us-east-1-597113427572"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        ConnectionArn    = "arn:aws:codestar-connections:us-east-1:233907574649:connection/13cf4aac-44f8-444e-a484-051d85a517fc"
        FullRepositoryId = "Su-informatics-lab/ardac-website"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      output_artifacts = ["BuildArtifact"]
      input_artifacts  = ["SourceArtifact"]

      configuration = {
        ProjectName = "ardac-website"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      version         = "1"
      input_artifacts = ["BuildArtifact"]

      configuration = {
        BucketName = "ardac.org"
        Extract    = "true"
      }
    }
  }
}