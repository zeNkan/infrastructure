data "aws_ecr_repository" "repo" {
  name = var.ecr_repo_name
}


data "aws_ecr_image" "lambda_image" {
  repository_name = data.aws_ecr_repository.repo.name
  image_tag = var.image_tag
}


data "aws_iam_policy_document" "lambda_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    } 
  }
}


resource "aws_iam_role" "lambda" {
  name = "${var.prefix}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_policy.json
}


resource "aws_cloudwatch_log_group" "minecraft-status" {
  name = "/aws/lambda/${aws_lambda_function.minecraft-status.function_name}"
  retention_in_days = 14
}


data "aws_iam_policy_document" "lambda" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect = "Allow"
    resources = [ "*" ]
    sid = "CreateCloudWatchLogs"
  }
}


resource "aws_iam_policy" "lambda-iam-policy" {
  name = "${var.prefix}-lambda-policy"
  path = "/"
  policy = data.aws_iam_policy_document.lambda.json
}


resource "aws_lambda_function" "minecraft-status" {
  function_name = "${var.prefix}-lambda"
  role = aws_iam_role.lambda.arn
  timeout = 300
  image_uri = "${data.aws_ecr_repository.repo.repository_url}@${data.aws_ecr_image.lambda_image.id}"
  package_type = "Image"

  environment {
    variables = {
      MC_SERVER_ADDR = "mc.backman.fyi"
      MC_SERVER_PORT = "25565"
    }
 }
}
