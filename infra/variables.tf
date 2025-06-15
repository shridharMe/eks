variable "region" {
  default = "eu-west-2"
}

# Variables for Docker Hub credentials
variable "dockerhub_username" {
  description = "Docker Hub username"
  type        = string
  sensitive   = true
  default     = "shridharpatil01"
}

variable "dockerhub_password" {
  description = "Docker Hub password"
  type        = string
  sensitive   = true
  default     = ""
}