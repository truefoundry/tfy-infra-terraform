# Generated Terraform configuration

# Configure the AWS provider
provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

# Define variables

variable "cluster_name" {
  type = string
}

variable "aws_profile" {
  type = string
}

variable "region" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}

variable "vpc_cidr" {
  type = string
}

variable "tenant_name" {
  type = string
}

variable "tenant_token" {
  type = string
}

variable "control_plane_url" {
  type = string
}

variable "tfy_api_key" {
  type = string
}

variable "truefoundry_image_pull_config_json" {
  type = string
}

variable "control_plane_install" {
  type = bool
}


# Configure Terraform backend
terraform {
  backend "s3" {
    bucket = "harshit-poc"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}



data "aws_subnet" "selected" {
  count = length(module.network.private_subnets_id)
  id    = module.network.private_subnets_id[count.index]
}

locals {
  tags = merge(
    {
      "terraform-module" = "efs"
      "terraform"        = "true"
      "cluster-name"     = var.cluster_name
    },
    var.tags
  )
  subnets = merge({ for _, v in data.aws_subnet.selected : v.availability_zone => v.id... })
  mount_targets = merge({ for k, v in local.subnets : k => {
    subnet_id = v[0]
  } })
}

# Add this data source after the existing aws_eks_cluster data source
data "aws_eks_cluster_auth" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

# Add this data source
data "aws_caller_identity" "current" {}

# Define modules

module "network" {
  source                = "truefoundry/truefoundry-network/aws"
  version               = "0.3.4"
  aws_account_id        = data.aws_caller_identity.current.account_id
  aws_region            = var.region
  azs                   = var.availability_zones
  cluster_name          = var.cluster_name
  flow_logs_enable      = false
  private_subnets_cidrs = ["10.10.0.0/20", "10.10.16.0/20", "10.10.32.0/20", "10.10.48.0/20"]
  private_subnets_ids   = []
  public_subnets_cidrs  = ["10.10.176.0/20", "10.10.192.0/20", "10.10.208.0/20", "10.10.224.0/20"]
  public_subnets_ids    = []
  shim                  = false
  tags                  = var.tags
  vpc_cidr              = var.vpc_cidr
  vpc_id                = null
}

module "eks" {
  source                                 = "truefoundry/truefoundry-cluster/aws"
  version                                = "0.6.4"
  cloudwatch_log_group_retention_in_days = "1"
  cluster_addons_coredns_version         = "v1.11.3-eksbuild.1"
  cluster_addons_kube_proxy_version      = "v1.29.7-eksbuild.5"
  cluster_addons_vpc_cni_version         = "v1.18.3-eksbuild.3"
  cluster_endpoint_public_access         = true
  cluster_endpoint_public_access_cidrs   = ["0.0.0.0/0"]
  cluster_name                           = var.cluster_name
  create_cloudwatch_log_group            = false
  node_security_group_additional_rules = {
    "ingress_control_plane_all" = {
      "type"        = "ingress"
      "cidr_blocks" = "${module.network.private_subnets_cidrs}"
      "description" = "Control plane to node all ports/protocols"
      "protocol"    = "-1"
      "from_port"   = 0
      "to_port"     = 0
    }
  }
  node_security_group_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "karpenter.sh/discovery"                    = "${var.cluster_name}"
  }
  subnet_ids = module.network.private_subnets_id
  tags       = var.tags
  vpc_id     = module.network.vpc_id
}

module "ebs" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.27.0"
  create_role                   = true
  oidc_fully_qualified_subjects = ["system:serviceaccount:aws-ebs-csi-driver:ebs-csi-controller-sa"]
  provider_url                  = module.eks.cluster_oidc_issuer_url
  role_name                     = "${var.cluster_name}-csi-ebs"
  role_policy_arns              = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
  tags                          = var.tags
}

module "efs" {
  source                        = "./terraform-aws-truefoundry-efs"
  azs                           = var.availability_zones
  mount_targets                 = local.mount_targets
  cluster_name                  = var.cluster_name
  cluster_oidc_issuer_url       = module.eks.cluster_oidc_issuer_url
  efs_node_iam_role_arn         = module.eks.eks_managed_node_groups.initial.iam_role_arn
  k8s_service_account_name      = "efs-csi-controller-sa"
  k8s_service_account_namespace = "aws-efs-csi-driver"
  performance_mode              = "generalPurpose"
  private_subnets_cidrs         = module.network.private_subnets_cidrs
  private_subnets_id            = module.network.private_subnets_id
  tags                          = var.tags
  throughput_mode               = "bursting"
  vpc_id                        = module.network.vpc_id
}

module "tfy-platform-features" {
  source                              = "truefoundry/truefoundry-platform-features/aws"
  version                             = "0.3.4"
  aws_account_id                      = data.aws_caller_identity.current.account_id
  aws_region                          = var.region
  blob_storage_enable_override        = false
  cluster_name                        = var.cluster_name
  control_plane_roles                 = ["arn:aws:iam::416964291864:role/tfy-ctl-euwe1-production-truefoundry-deps"]
  feature_blob_storage_enabled        = true
  feature_cluster_integration_enabled = true
  feature_docker_registry_enabled     = true
  feature_parameter_store_enabled     = true
  feature_secrets_manager_enabled     = false
  platform_feature_enabled            = true
  platform_role_enable_override       = false
  platform_user_enabled               = false
  platform_user_name_override_enabled = false
  tags                                = var.tags
}

module "aws-load-balancer-controller" {
  source                        = "truefoundry/truefoundry-load-balancer-controller/aws"
  version                       = "0.1.1"
  cluster_name                  = var.cluster_name
  cluster_oidc_provider_arn     = module.eks.oidc_provider_arn
  k8s_service_account_name      = "aws-load-balancer-controller"
  k8s_service_account_namespace = "aws-load-balancer-controller"
}

module "karpenter" {
  source                        = "truefoundry/truefoundry-karpenter/aws"
  version                       = "0.3.4"
  cluster_name                  = var.cluster_name
  controller_node_iam_role_arn  = module.eks.eks_managed_node_groups.initial.iam_role_arn
  controller_nodegroup_name     = "initial"
  k8s_service_account_name      = "karpenter"
  k8s_service_account_namespace = "karpenter"
  oidc_provider_arn             = module.eks.oidc_provider_arn
  tags                          = var.tags
}

module "tfy-control-plane" {
  source                                 = "truefoundry/truefoundry-control-plane/aws"
  version                                = "0.4.6"
  account_name                           = "devtest-${var.cluster_name}"
  aws_account_id                         = data.aws_caller_identity.current.account_id
  aws_region                             = var.region
  cluster_name                           = var.cluster_name
  cluster_oidc_issuer_url                = module.eks.cluster_oidc_issuer_url
  mlfoundry_k8s_namespace                = "truefoundry"
  mlfoundry_k8s_service_account          = "mlfoundry-server"
  mlfoundry_name                         = "mlfoundry-server"
  svcfoundry_k8s_namespace               = "truefoundry"
  svcfoundry_k8s_service_account         = "servicefoundry-server"
  svcfoundry_name                        = "servicefoundry-server"
  tags                                   = var.tags
  tfy_workflow_admin_k8s_namespace       = "truefoundry"
  tfy_workflow_admin_k8s_service_account = "tfy-workflow-admin"
  tfy_workflow_admin_name                = "tfy-workflow-admin"
  truefoundry_cloudwatch_log_exports     = []
  truefoundry_db_deletion_protection     = false
  truefoundry_db_engine_version          = "13.15"
  truefoundry_db_ingress_security_group  = module.eks.node_security_group_id
  truefoundry_db_instance_class          = "db.t4g.medium"
  truefoundry_db_max_allocated_storage   = "30"
  truefoundry_db_multiple_az             = false
  truefoundry_db_publicly_accessible     = true
  truefoundry_db_skip_final_snapshot     = true
  truefoundry_db_storage_encrypted       = true
  truefoundry_db_storage_iops            = "0"
  truefoundry_db_storage_type            = "gp3"
  truefoundry_db_subnet_ids              = module.network.public_subnets_id
  truefoundry_s3_force_destroy           = true
  vpc_id                                 = module.network.vpc_id
}

module "argocd" {
  source                 = "truefoundry/truefoundry-helm/kubernetes"
  version                = "0.1.0-rc.2"
  chart_name             = "argo-cd"
  chart_version          = "7.4.4"
  cluster_ca_certificate = module.eks.cluster_certificate_authority_data
  cluster_endpoint       = module.eks.cluster_endpoint
  create_namespace       = true
  namespace              = "argocd"
  release_name           = "argocd"
  repo_name              = "argo"
  repo_url               = "https://argoproj.github.io/argo-helm"
  set_values = {
    "server.extraArgs[1]"     = "--application-namespaces=*"
    "controller.extraArgs[0]" = "--application-namespaces=*"
    "applicationSet.enabled"  = "false"
    "notifications.enabled"   = "false"
    "dex.enabled"             = "false"
    "server.extraArgs[0]"     = "--insecure"
  }
  token = data.aws_eks_cluster_auth.cluster.token
}

module "truefoundry" {
  source                 = "truefoundry/truefoundry-helm/kubernetes"
  version                = "0.1.0-rc.2"
  chart_name             = "tfy-k8s-aws-eks-inframold"
  chart_version          = "0.1.2"
  cluster_ca_certificate = module.eks.cluster_certificate_authority_data
  cluster_endpoint       = module.eks.cluster_endpoint
  create_namespace       = true
  namespace              = "argocd"
  release_name           = "tfy-k8s-aws-eks-inframold"
  repo_name              = "truefoundry"
  repo_url               = "https://truefoundry.github.io/infra-charts"
  set_values = {
    "clusterName" = "${var.cluster_name}"
    "loki" = {
      "enabled" = true
    }
    "prometheus" = {
      "enabled" = true
      "additionalScrapeConfigs" = [{
        "scrape_interval" = "15s"
        "scrape_timeout"  = "10s"
        "metrics_path"    = "/metrics"
        "scheme"          = "http"
        "kubernetes_sd_configs" = [{
          "role" = "endpoints"
          "namespaces" = {
            "names" = ["tfy-gpu-operator"]
          }
        }]
        "relabel_configs" = [{
          "source_labels" = ["__meta_kubernetes_pod_node_name"]
          "action"        = "replace"
          "target_label"  = "kubernetes_node"
        }]
        "job_name" = "gpu-metrics"
      }]
    }
    "test" = {
      "enabled" = false
    }
    "tolerations" = [{
      "key"      = "CriticalAddonsOnly"
      "value"    = "true"
      "effect"   = "NoSchedule"
      "operator" = "Equal"
    }]
    "argoRollouts" = {
      "enabled" = true
    }
    "keda" = {
      "enabled" = true
    }
    "kubecost" = {
      "enabled" = true
    }
    "jspolicy" = {
      "enabled" = false
    }
    "tfyAgent" = {
      "enabled"      = true
      "clusterToken" = "${var.tenant_token}"
    }
    "elasti" = {
      "enabled" = false
    }
    "tenantName" = "${var.tenant_name}"
    "argoWorkflows" = {
      "enabled" = true
    }
    "aws" = {
      "inferentia" = {
        "enabled" = false
      }
      "awsLoadBalancerController" = {
        "roleArn" = "${module.aws-load-balancer-controller.elb_iam_role_arn}"
        "vpcId"   = "${module.network.vpc_id}"
        "region"  = "${var.region}"
        "enabled" = true
      }
      "karpenter" = {
        "enabled"           = true
        "clusterEndpoint"   = "${module.eks.cluster_endpoint}"
        "roleArn"           = "${module.karpenter.karpenter_role_arn}"
        "instanceProfile"   = "${module.karpenter.karpenter_instance_profile_id}"
        "defaultZones"      = "${var.availability_zones}"
        "interruptionQueue" = "${module.karpenter.karpenter_sqs_name}"
      }
      "awsEbsCsiDriver" = {
        "enabled" = true
        "roleArn" = "${module.ebs.iam_role_arn}"
      }
      "awsEfsCsiDriver" = {
        "region"       = "${var.region}"
        "roleArn"      = "${module.efs.efs_role_arn}"
        "enabled"      = true
        "fileSystemId" = "${module.efs.efs_id}"
      }
    }
    "truefoundry" = {
      "database" = {
        "host"     = "${module.tfy-control-plane.truefoundry_db_address}"
        "name"     = "${module.tfy-control-plane.truefoundry_db_database_name}"
        "username" = "${module.tfy-control-plane.truefoundry_db_username}"
        "password" = "${module.tfy-control-plane.truefoundry_db_password}"
      }
      "tfyApiKey"                      = "${var.tfy_api_key}"
      "truefoundryImagePullConfigJSON" = "${var.truefoundry_image_pull_config_json}"
      "enabled"                        = "${var.control_plane_install}"
      "devMode" = {
        "enabled" = false
      }
      "truefoundryBootstrap" = {
        "enabled" = true
      }
    }
    "istio" = {
      "enabled" = true
      "gateway" = {
        "annotations" = {
          "service.beta.kubernetes.io/aws-load-balancer-scheme"                            = "internet-facing"
          "service.beta.kubernetes.io/aws-load-balancer-alpn-policy"                       = "HTTP2Preferred"
          "service.beta.kubernetes.io/aws-load-balancer-backend-protocol"                  = "tcp"
          "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags"          = "cluster-name=${var.cluster_name},truefoundry.com/managed=true,owner=Truefoundry,application=tfy-istio-ingress"
          "service.beta.kubernetes.io/aws-load-balancer-name"                              = "${var.cluster_name}"
          "service.beta.kubernetes.io/aws-load-balancer-type"                              = "external"
          "service.beta.kubernetes.io/aws-load-balancer-ssl-cert"                          = "arn:aws:acm:eu-west-1:526077812922:certificate/48139a75-5445-4960-8548-04371a1605bb"
          "service.beta.kubernetes.io/aws-load-balancer-ssl-ports"                         = "https"
          "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" = "true"
        }
      }
      "discovery" = {
        "hub" = "gcr.io/istio-release"
        "tag" = "1.21.1-distroless"
      }
      "tfyGateway" = {
        "httpsRedirect" = true
      }
    }
    "grafana" = {
      "enabled" = false
    }
    "controlPlaneURL" = "${var.control_plane_url}"
    "argocd" = {
      "enabled" = true
    }
    "notebookController" = {
      "enabled"             = false
      "defaultStorageClass" = ""
    }
    "certManager" = {
      "enabled" = false
    }
    "metricsServer" = {
      "enabled" = true
    }
    "gpu" = {
      "clusterType" = "awsEks"
      "enabled"     = true
    }
  }
  token = data.aws_eks_cluster_auth.cluster.token
}


# Define outputs

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "host" {
  value = module.tfy-control-plane.truefoundry_db_address
}

output "name" {
  value = module.tfy-control-plane.truefoundry_db_database_name
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "private_subnets_id" {
  value = module.network.private_subnets_id
}

output "vpc_id" {
  value = module.network.vpc_id
}


