# Truefoundry Infrastructure Setup

This repository contains Terraform configurations to set up the Truefoundry infrastructure on AWS.

<!-- BEGIN_TF_DOCS -->

<!-- END_TF_DOCS -->

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
