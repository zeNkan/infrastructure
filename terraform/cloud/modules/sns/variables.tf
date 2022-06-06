variable "sns_topic_name" {
  description = "Name of the SNS Topic"
  type        = string
  default     = "default"
}

variable "sns_subscription_email" {
  description = "Email to send alert to"
  type        = string
}