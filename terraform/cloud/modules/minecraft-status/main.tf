data "aws_ecr_repository" "repo" {
  name = var.function_name
}


data "aws_ecr_image" "lambda_image" {
  repository_name = data.aws_ecr_repository.repo.name
  image_tag       = var.image_tag
}


data "aws_iam_policy_document" "lambda_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "lambda" {
  name               = "${var.function_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_policy.json
}


resource "aws_iam_role_policy_attachment" "lambda_cloudwatd_policy_attachment" {
  role       = aws_iam_role.lambda.id
  policy_arn = var.lambda_policy_arn
}


resource "aws_lambda_function" "minecraft-status" {
  function_name = "${var.function_name}-lambda"
  role          = aws_iam_role.lambda.arn
  timeout       = 300
  image_uri     = "${data.aws_ecr_repository.repo.repository_url}@${data.aws_ecr_image.lambda_image.id}"
  package_type  = "Image"

  environment {
    variables = {
      MC_SERVER_ADDR = var.mc_server_hostname
      MC_SERVER_PORT = var.mc_server_port
    }
  }
}
