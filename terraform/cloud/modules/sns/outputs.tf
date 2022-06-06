output "topic_arn" {
  description = "SNS Topic ARN"
  value       = aws_sns_topic.default.arn
}

output "subscription_arn" {
  description = "SNS Topic ARN"
  value       = aws_sns_topic_subscription.default.arn
}
