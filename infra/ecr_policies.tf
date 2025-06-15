# Custom policy for ECR pull-through cache
data "aws_iam_policy_document" "eks_node_custom_inline_policy" {
  statement {
    actions = [
      "ecr:CreateRepository",
      "ecr:ReplicateImage",
      "ecr:BatchImportUpstreamImage"
    ]

    resources = ["*"]
  }
}

# Create policy from the document
resource "aws_iam_policy" "ecr_pull_through_cache" {
  name        = "ECRPullThroughCachePolicy"
  description = "Policy for ECR pull-through cache operations"
  policy      = data.aws_iam_policy_document.eks_node_custom_inline_policy.json
}