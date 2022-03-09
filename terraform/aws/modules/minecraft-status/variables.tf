variable "image_tag" {
  type = string
  description = "The tage of the image to use"
}


variable "ecr_repo_name" {
  type = string
  description = "The name of the ECR repository name"
}

variable "prefix" {
  type = string
  description = "Resource prefix name"
}
