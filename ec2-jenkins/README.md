# Jenkins EC2 Infrastructure

This Terraform configuration provisions a Jenkins server on AWS EC2. The server will be automatically configured with initial admin credentials and a demo pipeline job.

## Prerequisites

- AWS credentials with appropriate permissions
- Terraform installed (>= 1.0.0)
- Existing VPC with subnets
- VPN or Direct Connect configured to access private resources in the VPC
- Public GitHub repository with a Jenkinsfile for the demo pipeline

## Usage

1. Create your `terraform.tfvars` file in the root folder. You can refer to `terraform.tfvars.example` as a template, but make sure to replace all `<PLACE_HOLDER>` values with your actual configuration. Pay special attention to:
   - Required AWS credentials
   - VPC and subnet IDs
   - GitHub repository URL (must be public and contain a Jenkinsfile)

2. Configure the variables in `terraform.tfvars`, ensuring to provide:
   - AWS credentials
   - VPC and subnet IDs
   - SSH public key (optional)
   - Jenkins configuration options
   - Valid public GitHub repository URL with Jenkinsfile

3. Initialize and apply Terraform:
   ```
   terraform init
   terraform apply
   ```

**Note:** The terraform apply process will take approximately 5-7 minutes as it:
- Provisions the EC2 instance
- Installs and configures Jenkins
- Creates initial admin user
- Install initial plugins from `jenkins_plugins`
- Sets up demo pipeline job with the specified public GitHub repository
- Waits 5 minutes before shutting down the instance

## Important Notes

- Make sure the VPC ID corresponds to a VPC in the specified AWS region (aws_region). The VPC and region must match or the deployment will fail.
- If you specify a private subnet ID, ensure `associate_public_ip_address` is set to `false`. The configuration will fail if you try to associate a public IP with an instance in a private subnet.
- After initial provisioning, the EC2 instance will be stopped. You'll need to start it manually from the AWS Console when needed.
- Jenkins will be accessible on port 8080. Since the instance is in a private subnet, you'll need VPN or Direct Connect to access it.
- The demo pipeline job requires a public GitHub repository that contains a Jenkinsfile in its root directory. Make sure your repository is:
  - Publicly accessible
  - Contains a valid Jenkinsfile
  - The Jenkinsfile is in the root directory of the repository

## Accessing Jenkins

1. Start the EC2 instance from AWS Console
2. Access Jenkins using: `http://<private-ip>:8080`
3. Login with configured credentials:
   - Username: Value of `init_admin_user` (default: admin)
   - Password: Value of `init_admin_password`

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | AWS region | string | us-east-1 | no |
| access_key | AWS access key | string | - | yes |
| secret_key | AWS secret key | string | - | yes |
| vpc_id | VPC ID where the instance will be created | string | - | yes |
| subnet_id | Subnet ID where the instance will be created | string | - | yes |
| instance_type | EC2 instance type | string | t3.micro | no |
| instance_name | Name of the EC2 instance | string | jenkins-server | no |
| public_key | Public key for SSH access | string | "" | no |
| associate_public_ip_address | Associate public IP with instance | bool | false | no |
| environment | Deployment environment | string | dev | no |
| volume_size | Size of root volume in GB | number | 20 | no |
| init_admin_user | Initial Jenkins admin username | string | admin | no |
| init_admin_password | Initial Jenkins admin password | string | your_secure_password | yes |
| jenkins_plugins | List of Jenkins plugins to install | list | <in variable.tf> | no |
| jenkins_job_name | Name of the initial pipeline job | string | demo-job | no |
| github_repo_url | GitHub repository URL for pipeline | string | - | yes |
| github_branch | GitHub branch for pipeline | string | main | no |

## Security

The EC2 instance is configured with a security group that allows:
- Port 22 (SSH)
- Port 80 (HTTP)
- Port 8080 (Jenkins)

Ensure your security requirements are met before deploying to production.