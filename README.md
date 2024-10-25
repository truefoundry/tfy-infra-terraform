# Truefoundry Infrastructure Setup

This repository contains Terraform configurations to set up the Truefoundry infrastructure on AWS.

## Prerequisites

1. AWS CLI installed and configured
2. Terraform installed (version 0.14.0 or later)
3. kubectl installed

## Setup Instructions

1. Clone this repository:   ```
   git clone <repository-url>
   cd <repository-directory>   ```

2. Copy the tfvars template and fill in your values:   ```
   cp tfy.tfvars.template tfy.tfvars   ```
   Edit `tfy.tfvars` and replace the placeholder values with your actual configuration.

3. Initialize Terraform:   ```
   terraform init   ```

4. Plan the infrastructure changes:   ```
   terraform plan -var-file=tfy.tfvars   ```

5. Apply the changes:   ```
   terraform apply -var-file=tfy.tfvars   ```

6. After successful application, configure kubectl to interact with your new EKS cluster:   ```
   aws eks update-kubeconfig --name <cluster-name> --region <aws-region>   ```

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
