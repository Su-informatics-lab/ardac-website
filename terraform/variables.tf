variable "config" {
  description = "Path to AWS config file"
  type        = list(string)
}

variable "credentials" {
  description = "Path to AWS credentials file"
  type        = list(string)
}

variable "profile" {
  description = "Name of AWS credentials profile"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "account" {
  description = "AWS account"
  type        = string
}

variable "distribution" {
  description = "CloudFront distribution ID"
  type        = string
}