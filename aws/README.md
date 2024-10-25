# Truefoundry Infrastructure Setup on AWS

This repository contains Terraform configurations to set up the Truefoundry infrastructure on AWS.

<!-- BEGIN_TF_DOCS -->
## Requirements

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Installation](#installation)
4. [Post-Installation](#post-installation)
5. [Troubleshooting](#troubleshooting)
6. [Cleanup](#cleanup)
7. [Known Issues](#known-issues)
8. [Next Steps](#next-steps)
9. [Terraform Documentation](#terraform-documentation)

## Prerequisites

Ensure you have the following tools installed:

| Tool      | Version  |
|-----------|----------|
| AWS CLI   | 2.17.50+ |
| Terraform | v1.9.8+  |
| kubectl   | v1.31.1+ |
| Git       | 2.39.5+  |

Additionally, you need:

- Access to an AWS account with necessary permissions
- A Truefoundry account and API key
- An Amazon S3 bucket for storing Terraform state

## Initial Setup

1. **Create S3 Bucket for Terraform State**

   ```bash
   aws s3api create-bucket --bucket your-terraform-state-bucket-name --region your-aws-region
   aws s3api put-bucket-versioning --bucket your-terraform-state-bucket-name --versioning-configuration Status=Enabled
   ```

2. **Update `backend.tf`**

   ```hcl
   terraform {
     backend "s3" {
       bucket = "your-terraform-state-bucket-name"
       key    = "terraform.tfstate"
       region = "your-aws-region"
     }
   }
   ```

3. **Prepare Configuration**

   ```bash
   cp tfy.tfvars.template tfy.tfvars
   # Edit tfy.tfvars with your configuration
   ```

## Installation

1. **Clone Repository**

   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Initialize Terraform**

   ```bash
   terraform init
   ```

3. **Apply Network Module**

   ```bash
   terraform plan -target module.network -var-file=tfy.tfvars
   terraform apply -target=module.network -var-file=tfy.tfvars
   ```

4. **Apply Remaining Modules**

   ```bash
   terraform apply -var-file=tfy.tfvars
   ```

## Post-Installation

1. **Configure kubectl**

   ```bash
   export REGION=<your-aws-region>
   export AWS_PROFILE=<your-aws-profile>
   export CLUSTER_NAME=<your-cluster-name>
   aws eks --region $REGION --profile $AWS_PROFILE update-kubeconfig --name $CLUSTER_NAME
   ```

2. **Verify Cluster Connection**

   ```bash
   kubectl get nodes
   ```

3. **Confirm Helm Chart Installation**

   ```bash
   helm list -n argocd
   ```

4. **Verify Control Plane**

   ```bash
   kubectl get pods -n truefoundry
   ```

5. **Confirm ArgoCD Apps**

   ```bash
   argocd app list
   ```

## Troubleshooting

If you encounter issues:

1. Verify all prerequisites are correctly installed and configured.
2. Ensure AWS credentials have necessary permissions.
3. Check Terraform and kubectl logs for error messages.
4. Consult Truefoundry documentation for specific component issues.

For additional support, contact Truefoundry support or consult community forums.

## Cleanup

To remove all created resources:

```bash
terraform destroy -var-file=tfy.tfvars
```

## Known Issues

1. **Karpenter Nodes**: May require manual deletion.
2. **Security Groups**: Check for lingering deletions.
3. **Persistent Volumes**: Not automatically removed, manual deletion required for:
   - ArgoCD resources (Grafana, Kubecost, Truefoundry, Prometheus, Loki)
4. **EBS Volumes**: Check and delete manually.
5. **Endpoints**: Manually delete EFS and GuardDuty endpoints.

## Next Steps

After successful installation:

1. Set up monitoring and logging
2. Configure backup and disaster recovery
3. Implement security best practices

## Terraform Documentation

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
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | n/a |
| <a name="output_host"></a> [host](#output\_host) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | n/a |
| <a name="output_private_subnets_id"></a> [private\_subnets\_id](#output\_private\_subnets\_id) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | n/a |
<!-- END_TF_DOCS -->
