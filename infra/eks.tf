################################################################################
# Cluster
################################################################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.23.0"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true

  cluster_addons = {
    kube-proxy = { most_recent = true }
    coredns    = { most_recent = true }

    vpc-cni = {
      most_recent    = true
      before_compute = true
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  create_cloudwatch_log_group              = false
  create_cluster_security_group            = false
  create_node_security_group               = false
  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    mg_5 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["m4.large"]

      create_security_group = false

      subnet_ids   = module.vpc.private_subnets
      max_size     = 1
      desired_size = 1
      min_size     = 1

      # Launch template configuration
      create_launch_template = true              # false will use the default launch template
      launch_template_os     = "amazonlinux2eks" # amazonlinux2eks or bottlerocket

      labels = {
        intent = "control-apps"
      }
    }
    # m8xl-spot ={
    #    node_group_name= "managed-m8xl-spot"
    #    instance_types =["m6i.8xlarge", "m6id.8xlarge", "m5d.8xlarge" ,"m7i.8xlarge" ,"m5.8xlarge" ,"m6in.8xlarge" ,"m5dn.8xlarge","m5n.8xlarge"]
    #    create_security_group = false
    #    subnet_ids   = module.vpc.private_subnets
    #     max_size     = 2
    #     desired_size = 1
    #     min_size     = 0
    #     # Launch template configuration
    #     create_launch_template = true              # false will use the default launch template
    #     launch_template_os     = "amazonlinux2eks" # amazonlinux2eks or bottlerocket
    #     labels = {
    #     "Environment" = "test"
    #     GithubRepo  = "terraform-aws-eks"
    #     GithubOrg   = "terraform-aws-modules"
    #    }

    # }




  }

  tags = merge(local.tags, {
    "karpenter.sh/discovery" = local.name
  })
}