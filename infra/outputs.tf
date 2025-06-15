output "karpenter_instance_profile" {
  value = module.eks_blueprints_addons.karpenter.node_instance_profile_name
}

output "aws_eks_config" {
  value = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}"
}

# Output the pull-through cache URL
output "pull_through_cache_url" {
  value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/dockerhub/library/"
}
