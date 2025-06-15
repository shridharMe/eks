module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "1.16.3"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  create_delay_dependencies = [for prof in module.eks.eks_managed_node_groups : prof.node_group_arn]

  #   enable_aws_load_balancer_controller = true
  enable_metrics_server = true

  enable_karpenter          = true
  enable_cluster_autoscaler = true
  cluster_autoscaler = {
    set = [


      {
        name  = "extraArgs.balance-similar-node-groups"
        value = "true"
      },
      {
        name  = "extraArgs.expander"
        value = "priority"
      },
      {
        name  = "extraArgs.scale-down-utilization-threshold"
        value = "0.9"
      },
      {
        name  = "extraArgs.scale-down-enabled"
        value = "true"
      },
      {
        name  = "extraArgs.scale-down-delay-after-add"
        value = "1m"
      },
      {
        name  = "extraArgs.scale-down-delay-after-delete"
        value = "1m"
      },
      {
        name  = "extraArgs.scale-down-delay-after-failure"
        value = "1m"
      },
      {
        name  = "extraArgs.scale-down-unneeded-time"
        value = "1m"
      },
      {
        name  = "extraArgs.skip-nodes-with-system-pods"
        value = "false"
      },
      {
        name  = "extraArgs.expendable-pods-priority-cutoff"
        value = "-10"
      },
      {
        name  = "extraArgs.max-graceful-termination-sec"
        value = "600"
      }
    ],
    values = [
      <<-EOT
      expanderPriorities:
        # 40:
        #   - ".*40-pmanaged-m8xl-spot.*"
        #   - ".*eks-managed-m8xl-spot.*"
        30:
          - ".*30p-managed-m24xl-spot.*"
          - ".*30p-managed-m16xl-spot.*"
          - ".*30p-eks-managed-m24xl-spot.*"
          - ".*30p-eks-managed-m16xl-spot.*"
        20:
          - ".*20p-managed-m8xl-od.*"
          - ".*20p-eks-managed-m8xl-od.*"
        15:
          - ".*15p-managed-m16xl-od.*"
          - ".*15p-eks-managed-m16xl-od.*"
        50:
          - ".*default-ng.*"
          - ".*eks-default-ng.*"
      podAnnotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8085"
        prometheus.io/path: "/metrics"
      EOT
    ]
  }
  karpenter = {
    chart_version       = "1.3.2"
    repository_username = data.aws_ecrpublic_authorization_token.token.user_name
    repository_password = data.aws_ecrpublic_authorization_token.token.password
    set = [
      {
        name  = "replicas"
        value = 1
    }]
  }
  karpenter_enable_spot_termination          = true
  karpenter_enable_instance_profile_creation = true

  karpenter_node = {
    iam_role_use_name_prefix = false
  }

  tags = local.tags
}



module "aws-auth" {
  source                    = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version                   = "~> 20.0"
  manage_aws_auth_configmap = true
  aws_auth_roles = [
    {
      rolearn  = module.eks_blueprints_addons.karpenter.node_iam_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    },
  ]
}