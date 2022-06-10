variable "image_tag" {
  type        = string
  description = "The tage of the image to use"
}

variable "function_name" {
  type        = string
  description = "The name of the ECR repository name"
}

variable "mc_server_hostname" {
  type        = string
  description = "The name of the ECR repository name"
}

variable "mc_server_port" {
  type        = string
  description = "The name of the ECR repository name"
}

variable "lambda_policy_arn" {
  type        = string
  description = "ARN of policy to attatch to lambda"
  default     = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
