# Truefoundry Infrastructure Setup

This repository contains Terraform configurations to set up the Truefoundry infrastructure on AWS.

## Prerequisites

| Tool      | Version  |
|-----------|----------|
| AWS CLI   | 2.17.50  |
| Terraform | v1.9.8   |
| kubectl   | v1.31.1  |
| Git       | 2.39.5   |

- Access to AWS account with necessary permissions
- Truefoundry account and API key
- Amazon S3 bucket created for storing Terraform state

## Initialization

Before you begin, make sure you have the following information ready:

- AWS account credentials
- Truefoundry tenant name and token
- Desired AWS region and availability zones
- VPC CIDR block

### Create S3 Bucket for Terraform State

1. Create an S3 bucket to store the Terraform state:

```
   aws s3api create-bucket --bucket your-terraform-state-bucket-name --region your-aws-region   
   ```

   Replace `your-terraform-state-bucket-name` with a unique bucket name and `your-aws-region` with your desired AWS region.

2. Enable versioning on the bucket:

```
   aws s3api put-bucket-versioning --bucket your-terraform-state-bucket-name --versioning-configuration Status=Enabled   
   ```

3. Update the `backend.tf` file with your bucket name:

```hcl
   terraform {
     backend "s3" {
       bucket = "your-terraform-state-bucket-name"
       key    = "terraform.tfstate"
       region = "your-aws-region"
     }
   }
   ```

## Setup Instructions

1. Clone this repository:

```
   git clone <repository-url>
   cd <repository-directory>   
   ```

2. Copy the tfvars template and fill in your values:  

```
   cp tfy.tfvars.template tfy.tfvars   
   ```

   Edit `tfy.tfvars` and replace the placeholder values with your actual configuration.

3. Initialize Terraform with the upgrade option:  

 ```
   terraform init    ```

4. Plan the Network module changes:  
```

   terraform plan -target module.network -var-file=tfy.tfvars

   ```

5. Apply the Network module changes:  
```

   terraform apply -target=module.network -var-file=tfy.tfvars

   ```

6. After successful application, configure kubectl to interact with your new EKS cluster:  
```

   aws eks update-kubeconfig --name <cluster-name> --region <aws-region>   ```

8. Configure kubectl:

   ```
   export REGION=<your-aws-region>
   export AWS_PROFILE=<your-aws-profile>
   export CLUSTER_NAME=<your-cluster-name>
   aws eks --region $REGION --profile $AWS_PROFILE update-kubeconfig --name $CLUSTER_NAME
   ```

   This will update your kubeconfig and set the new kubectl context.

9. Verify the cluster connection:

   ```
   kubectl get nodes
   ```

10. Confirm Helm chart installation:

    ```
    helm list -A
    ```

    This will show all installed Helm charts across all namespaces.

11. Check Tfy-istio-ingress:

    ```
    kubectl get svc -n istio-system
    ```

    Look for the `tfy-istio-ingress` service.

12. Set Up DNS and ACM:
    a. Obtain the Load Balancer DNS name:

       ```
       kubectl get svc -n istio-system tfy-istio-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
       ```

    b. In your DNS provider, create a CNAME record pointing your desired domain to this Load Balancer DNS name.
    c. Request an ACM certificate for your domain:

       ```
       aws acm request-certificate --domain-name yourdomain.com --validation-method DNS --region $REGION
       ```

    d. Follow the instructions provided by AWS to validate the certificate using DNS validation.

13. Verify Control Plane:
    a. Check the status of the control plane pods:

       ```
       kubectl get pods -n truefoundry
       ```

       Ensure all pods are in the 'Running' state.
    b. Access the control plane URL in your browser to verify it's up and running.

14. Confirm ArgoCD apps:
    - Via CLI:

     ```
      argocd app list      
      ```

    - Or check the ArgoCD UI for the list of applications and their sync status.

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
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | n/a | `list(string)` | n/a | yes |
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | n/a | `any` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `any` | n/a | yes |
| <a name="input_control_plane_install"></a> [control\_plane\_install](#input\_control\_plane\_install) | n/a | `any` | n/a | yes |
| <a name="input_control_plane_url"></a> [control\_plane\_url](#input\_control\_plane\_url) | n/a | `any` | n/a | yes |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | n/a | `list(string)` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | n/a | `list(string)` | n/a | yes |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | n/a | `list(string)` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | n/a | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `any` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | n/a | yes |
| <a name="input_tenant_name"></a> [tenant\_name](#input\_tenant\_name) | n/a | `any` | n/a | yes |
| <a name="input_tenant_token"></a> [tenant\_token](#input\_tenant\_token) | n/a | `any` | n/a | yes |
| <a name="input_tfy_api_key"></a> [tfy\_api\_key](#input\_tfy\_api\_key) | n/a | `any` | n/a | yes |
| <a name="input_truefoundry_image_pull_config_json"></a> [truefoundry\_image\_pull\_config\_json](#input\_truefoundry\_image\_pull\_config\_json) | n/a | `any` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | n/a | `any` | n/a | yes |

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
## Variable Descriptions

- `cluster_name`: Name of your EKS cluster
- `aws_profile`: AWS CLI profile to use
- `region`: AWS region to deploy resources
- `availability_zones`: List of availability zones to use in the specified region
- `vpc_cidr`: CIDR block for the VPC
- `tenant_name`: Name of your Truefoundry tenant
- `tenant_token`: Token for your Truefoundry tenant
- `control_plane_url`: URL of the Truefoundry control plane
- `tags`: Map of tags to apply to resources

## Install Control Plane

- `tfy_api_key`: API key for Truefoundry
- `truefoundry_image_pull_config_json`: JSON configuration for pulling Truefoundry images
- `control_plane_install`: Boolean flag to control installation of the control plane

## Outputs

After applying the Terraform configuration, you'll see several outputs including:

- Cluster endpoint
- Truefoundry database address and name
- OIDC provider ARN
- Private subnet IDs
- VPC ID

These can be useful for further configuration or for connecting to your resources.

## Troubleshooting

If you encounter any issues during the installation process, please check the following:

1. Ensure all prerequisites are correctly installed and configured.
2. Verify that your AWS credentials have the necessary permissions.
3. Check the Terraform and kubectl logs for any error messages.
4. Consult the Truefoundry documentation for specific component issues.

For additional support, please contact Truefoundry support or consult the community forums.

## Cleanup

To remove all created resources:

1. Destroy the Terraform-managed infrastructure:   ```
   terraform destroy -var-file=tfy.tfvars   ```

2. Confirm the deletion of resources in your AWS console.

Note: This action will delete all resources created by this Terraform configuration. Make sure to backup any important data before proceeding.

## Next Steps

After successful installation, consider the following next steps:

1. Set up monitoring and logging
2. Configure backup and disaster recovery
3. Implement security best practices
