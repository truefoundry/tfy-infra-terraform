# Truefoundry Infrastructure Setup on AWS

This repository contains Terraform configurations to set up the Truefoundry infrastructure on AWS.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_argocd"></a> [argocd](#module\_argocd) | truefoundry/truefoundry-helm/kubernetes | 0.1.0-rc.2 |
| <a name="module_aws-load-balancer-controller"></a> [aws-load-balancer-controller](#module\_aws-load-balancer-controller) | truefoundry/truefoundry-load-balancer-controller/aws | 0.1.1 |
| <a name="module_ebs"></a> [ebs](#module\_ebs) | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | 5.27.0 |
| <a name="module_efs"></a> [efs](#module\_efs) | truefoundry/truefoundry-efs/aws | 0.3.4 |
| <a name="module_eks"></a> [eks](#module\_eks) | truefoundry/truefoundry-cluster/aws | 0.6.4 |
| <a name="module_karpenter"></a> [karpenter](#module\_karpenter) | truefoundry/truefoundry-karpenter/aws | 0.3.4 |
| <a name="module_network"></a> [network](#module\_network) | truefoundry/truefoundry-network/aws | 0.3.4 |
| <a name="module_tfy-control-plane"></a> [tfy-control-plane](#module\_tfy-control-plane) | truefoundry/truefoundry-control-plane/aws | 0.4.6 |
| <a name="module_tfy-platform-features"></a> [tfy-platform-features](#module\_tfy-platform-features) | truefoundry/truefoundry-platform-features/aws | 0.3.4 |
| <a name="module_truefoundry"></a> [truefoundry](#module\_truefoundry) | truefoundry/truefoundry-helm/kubernetes | 0.1.0-rc.2 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zones to use in the specified region | `list(string)` | n/a | yes |
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | AWS CLI profile to use | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_control_plane_install"></a> [control\_plane\_install](#input\_control\_plane\_install) | Boolean flag to control installation of the control plane | `bool` | n/a | yes |
| <a name="input_control_plane_url"></a> [control\_plane\_url](#input\_control\_plane\_url) | URL of the Truefoundry control plane | `string` | n/a | yes |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | List of CIDR blocks for private subnets | `list(string)` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | List of IDs for private subnets | `list(string)` | n/a | yes |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | List of CIDR blocks for public subnets | `list(string)` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | List of IDs for public subnets | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region to deploy resources | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to apply to resources | `map(string)` | n/a | yes |
| <a name="input_tenant_name"></a> [tenant\_name](#input\_tenant\_name) | Name of your Truefoundry tenant | `string` | n/a | yes |
| <a name="input_tenant_token"></a> [tenant\_token](#input\_tenant\_token) | Token for your Truefoundry tenant | `string` | n/a | yes |
| <a name="input_tfy_api_key"></a> [tfy\_api\_key](#input\_tfy\_api\_key) | API key for Truefoundry | `string` | n/a | yes |
| <a name="input_truefoundry_image_pull_config_json"></a> [truefoundry\_image\_pull\_config\_json](#input\_truefoundry\_image\_pull\_config\_json) | JSON configuration for pulling Truefoundry images | `string` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for the VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | EKS cluster endpoint |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | OIDC provider ARN |
| <a name="output_private_subnets_id"></a> [private\_subnets\_id](#output\_private\_subnets\_id) | Private subnets IDs |
| <a name="output_truefoundry_db_address"></a> [truefoundry\_db\_address](#output\_truefoundry\_db\_address) | Truefoundry database address |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |
<!-- END_TF_DOCS -->
