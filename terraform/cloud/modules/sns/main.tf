resource "aws_sns_topic" "default" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_subscription" "default" {
  topic_arn = aws_sns_topic.default.arn
  endpoint  = var.sns_subscription_email
  protocol  = "email"
}