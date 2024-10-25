# Truefoundry Infrastructure Setup

This repository contains Terraform configurations to set up the Truefoundry infrastructure on AWS.

## Prerequisites

1. AWS CLI installed and configured
2. Terraform installed (version 0.14.0 or later)
3. kubectl installed
4. Git installed
5. Access to AWS account with necessary permissions
6. Truefoundry account and API key

## Initialization

Before you begin, make sure you have the following information ready:

- AWS account credentials
- Truefoundry tenant name and token
- Truefoundry control plane URL and API key
- Desired AWS region and availability zones
- VPC CIDR block

### Create S3 Bucket for Terraform State

1. Create an S3 bucket to store the Terraform state:   ```
   aws s3api create-bucket --bucket your-terraform-state-bucket-name --region your-aws-region   ```
   Replace `your-terraform-state-bucket-name` with a unique bucket name and `your-aws-region` with your desired AWS region.

2. Enable versioning on the bucket:   ```
   aws s3api put-bucket-versioning --bucket your-terraform-state-bucket-name --versioning-configuration Status=Enabled   ```

3. Update the `backend.tf` file with your bucket name:   ```hcl
   terraform {
     backend "s3" {
       bucket = "your-terraform-state-bucket-name"
       key    = "terraform.tfstate"
       region = "your-aws-region"
     }
   }```

## Setup Instructions

1. Clone this repository:   ```
   git clone <repository-url>
   cd <repository-directory>   ```

2. Copy the tfvars template and fill in your values:   ```
   cp tfy.tfvars.template tfy.tfvars   ```
   Edit `tfy.tfvars` and replace the placeholder values with your actual configuration.

3. Initialize Terraform with the upgrade option:   ```
   terraform init -upgrade   ```

4. Plan the infrastructure changes:   ```
   terraform plan -var-file=tfy.tfvars   ```

5. Apply the EKS module changes:   ```
   terraform apply -target=module.eks -var-file=tfy.tfvars   ```

6. Apply the changes for the entire stack:   ```
   terraform apply -var-file=tfy.tfvars   ```

7. After successful application, configure kubectl to interact with your new EKS cluster:   ```
   aws eks update-kubeconfig --name <cluster-name> --region <aws-region>   ```

8. Verify the cluster connection:   ```
   kubectl get nodes   ```

9. Install Truefoundry components:   ```
   kubectl apply -f truefoundry-components.yaml   ```

10. Verify Truefoundry installation:    ```
    kubectl get pods -n truefoundry-system    ```

11. Access Truefoundry dashboard:
    - Retrieve the Truefoundry dashboard URL from the Terraform outputs
    - Open the URL in a web browser and log in with your Truefoundry credentials

## Variable Descriptions

- `cluster_name`: Name of your EKS cluster
- `aws_profile`: AWS CLI profile to use
- `region`: AWS region to deploy resources
- `availability_zones`: List of availability zones to use in the specified region
- `vpc_cidr`: CIDR block for the VPC
- `tenant_name`: Name of your Truefoundry tenant
- `tenant_token`: Token for your Truefoundry tenant
- `control_plane_url`: URL of the Truefoundry control plane
- `tfy_api_key`: API key for Truefoundry
- `truefoundry_image_pull_config_json`: JSON configuration for pulling Truefoundry images
- `control_plane_install`: Boolean flag to control installation of the control plane
- `tags`: Map of tags to apply to resources

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
