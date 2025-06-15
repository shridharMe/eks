

# Create a pull-through cache rule for Docker Hub
resource "aws_ecr_pull_through_cache_rule" "dockerhub" {
  ecr_repository_prefix = "dockerhub"
  upstream_registry_url = "registry-1.docker.io"
  credential_arn        = aws_secretsmanager_secret.dockerhub_creds.arn
}

# Configure ECR registry settings for high pull throughput
resource "aws_ecr_registry_policy" "high_throughput" {
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowConcurrentPulls",
        Effect = "Allow",
        Principal = {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ],
        Resource = "*"
      }
    ]
  })
}


# Create a secret for Docker Hub credentials
resource "aws_secretsmanager_secret" "dockerhub_creds" {
  name = "ecr-pullthroughcache/dockerhub-credentials"
}

# Store Docker Hub credentials in the secret
resource "aws_secretsmanager_secret_version" "dockerhub_creds" {
  secret_id = aws_secretsmanager_secret.dockerhub_creds.id
  secret_string = jsonencode({
    username    = var.dockerhub_username
    accessToken = var.dockerhub_password
  })
}