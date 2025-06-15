
# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get current AWS region
data "aws_region" "current" {}



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
          WARM_ENI_TARGET          = "1"
        }
      })
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  create_cloudwatch_log_group              = false
  create_cluster_security_group            = true
  create_node_security_group               = true
  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true
  eks_managed_node_group_defaults = {
    iam_role_additional_policies = {
      AmazonECRPullThroughCache          = aws_iam_policy.ecr_pull_through_cache.arn
      AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
      AmazonEKS_CNI_Policy               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
      AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
      AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }

  eks_managed_node_groups = {
    m7i_xlarge = {

      name            = "default-ng"
      use_name_prefix = false

      instance_types = ["m7i.xlarge"]

      create_security_group = true

      subnet_ids = module.vpc.private_subnets

      max_size     = 1
      desired_size = 1
      min_size     = 1

      # Launch template configuration
      create_launch_template = true
      launch_template_os     = "al2023"

      # Add bootstrap arguments with allowed node labels only
      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=intent=control-apps'"
      labels = {
        intent = "control-apps"
      }
    }

    m8xl-spot = {
      name                  = "40p-managed-m8xl-spot"
      use_name_prefix       = false
      instance_types        = ["m6i.8xlarge", "m6id.8xlarge", "m5d.8xlarge", "m7i.8xlarge", "m5.8xlarge", "m6in.8xlarge", "m5n.8xlarge"]
      create_security_group = true
      subnet_ids            = module.vpc.private_subnets
      max_size              = 2
      desired_size          = 0
      min_size              = 0
      # Launch template configuration
      create_launch_template = true
      launch_template_os     = "al2023"
      capacity_type          = "SPOT"

      # Add bootstrap arguments with allowed node labels only
      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=intent=spot'"
      labels = {
        "k8s.citi.com/lifecycle" : "spot"
      }

      taints = {
        spot_noExecute = {
          key    = "k8s.citi.com/lifecycle"
          value  = "spot"
          effect = "NO_EXECUTE"
        }
        spot_noSchedule = {
          key    = "k8s.citi.com/lifecycle"
          value  = "spot"
          effect = "NO_SCHEDULE"
        }
      }
    }
    m24xl-spot = {
      name            = "30p-managed-m24xl-spot"
      use_name_prefix = false
      instance_types = [
        "m7i.24xlarge", "m6id.24xlarge", "m6i.24xlarge", "m6idn.24xlarge", "m5.24xlarge", "m5n.24xlarge", "m5d.24xlarge", "m6in.24xlarge"
      ]
      create_security_group = true
      subnet_ids            = module.vpc.private_subnets
      max_size              = 450
      desired_size          = 0
      min_size              = 0
      # Launch template configuration
      create_launch_template = true
      launch_template_os     = "al2023"
      capacity_type          = "SPOT"

      # Add bootstrap arguments with allowed node labels only
      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=intent=spot'"
      labels = {
        "k8s.citi.com/lifecycle" : "spot"
      }

      taints = {
        spot_noExecute = {
          key    = "k8s.citi.com/lifecycle"
          value  = "spot"
          effect = "NO_EXECUTE"
        }
        spot_noSchedule = {
          key    = "k8s.citi.com/lifecycle"
          value  = "spot"
          effect = "NO_SCHEDULE"
        }
      }
    }

    m16xl-spot = {
      name            = "30p-managed-m16xl-spot"
      use_name_prefix = false
      instance_types = [
        "m7i.16xlarge", "m6id.16xlarge", "m6in.16xlarge", "m6idn.16xlarge", "m5.16xlarge", "m5n.16xlarge", "m5d.16xlarge"
      ]
      create_security_group = true
      subnet_ids            = module.vpc.private_subnets
      max_size              = 450
      desired_size          = 0
      min_size              = 0
      # Launch template configuration
      create_launch_template = true
      launch_template_os     = "al2023"
      capacity_type          = "SPOT"

      # Add bootstrap arguments with allowed node labels only
      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=intent=spot'"

      labels = {
        "k8s.citi.com/lifecycle" : "spot"
      }

      taints = {
        spot_noExecute = {
          key    = "k8s.citi.com/lifecycle"
          value  = "spot"
          effect = "NO_EXECUTE"
        }
        spot_noSchedule = {
          key    = "k8s.citi.com/lifecycle"
          value  = "spot"
          effect = "NO_SCHEDULE"
        }
      }
    }

    m8xl-od = {
      name                  = "20p-managed-m8xl-od"
      use_name_prefix       = false
      instance_types        = ["m6i.8xlarge", "m6id.8xlarge", "m5d.8xlarge", "m7i.8xlarge", "m5.8xlarge", "m6in.8xlarge", "m5n.8xlarge"]
      create_security_group = true
      subnet_ids            = module.vpc.private_subnets
      max_size              = 2
      desired_size          = 0
      min_size              = 0
      # Launch template configuration
      create_launch_template = true
      launch_template_os     = "al2023"

      # Add bootstrap arguments with allowed node labels only
      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=intent=ondemand'"

      labels = {
        "k8s.citi.com/lifecycle" : "spot"
      }

      taints = {
        spot_noExecute = {
          key    = "k8s.citi.com/lifecycle"
          value  = "spot"
          effect = "NO_EXECUTE"
        }
        spot_noSchedule = {
          key    = "k8s.citi.com/lifecycle"
          value  = "spot"
          effect = "NO_SCHEDULE"
        }
      }
    }

    m16xl-od = {
      name            = "15p-managed-m16xl-od"
      use_name_prefix = false
      instance_types = [
        "m7i.16xlarge", "m6id.16xlarge", "m6in.16xlarge", "m6idn.16xlarge", "m5.16xlarge", "m5n.16xlarge", "m5d.16xlarge"
      ]
      create_security_group = true
      subnet_ids            = module.vpc.private_subnets
      max_size              = 450
      desired_size          = 0
      min_size              = 0
      # Launch template configuration
      create_launch_template = true
      launch_template_os     = "al2023"

      # Add bootstrap arguments with allowed node labels only
      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=intent=ondemand'"

      labels = {
        "k8s.citi.com/lifecycle" : "spot"
      }

      taints = {
        spot_noExecute = {
          key    = "k8s.citi.com/lifecycle"
          value  = "spot"
          effect = "NO_EXECUTE"
        }
        spot_noSchedule = {
          key    = "k8s.citi.com/lifecycle"
          value  = "spot"
          effect = "NO_SCHEDULE"
        }
      }
    }
  }
  tags = merge(local.tags, {
    "karpenter.sh/discovery" = local.name
  })
}