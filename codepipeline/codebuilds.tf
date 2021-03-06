resource "aws_codebuild_project" "build_project" {
  name          = "build_project"
  description   = "Sample build project"
  build_timeout = 5
  service_role  = aws_iam_role.codepipeline-role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:1.0"
    type                        = "LINUX_CONTAINER"
    #image_pull_credentials_type = "SERVICE_ROLE"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = var.build_log_group_name
      stream_name = var.build_log_stream_name
    }
  }
  
  source {
    type      = "S3"
    location  = "${aws_s3_bucket.s3-bucket.bucket}/${var.source_bucket_key}"
    buildspec = "codepipeline/buildspec.yml"
  }

  source_version = "master"

  vpc_config {
    vpc_id = data.aws_vpc.selected.id
    subnets = data.aws_subnet_ids.selected.ids
    security_group_ids = [aws_security_group.pipeline_default.id]
  }
}

