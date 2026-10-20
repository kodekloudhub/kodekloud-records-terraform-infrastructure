variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "eu-west-2"
}

variable "iam_usernames" {
  description = "List of IAM usernames to create"
  type        = list(string)
}
