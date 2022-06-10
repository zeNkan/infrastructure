output "lambda_name" {
  description = "Name of the lambda function created"
  value       = aws_lambda_function.minecraft-status.function_name
}

output "lambda_arn" {
  description = "ARN of the lambda function created"
  value       = aws_lambda_function.minecraft-status.arn
}

