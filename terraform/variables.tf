variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "app_name" {
  default = "fastapi-app"
}

variable "github_username" {
  default = "hafiz11339"
}


variable "deploy_public_key" {
  description = "Public SSH key for GitHub Actions"
}