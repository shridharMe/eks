output "karpenter_instance_profile" {
  value = module.eks_blueprints_addons.karpenter.node_instance_profile_name
}

output "aws_eks_config" {
  value = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}"
}

