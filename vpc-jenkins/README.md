# Jenkins VPC Infrastructure

This Terraform configuration provisions a VPC on AWS specifically designed for hosting Jenkins servers. It creates a network infrastructure with public and private subnets across multiple availability zones, NAT gateway for internet access from private subnets, and appropriate routing.

## Features

- **Multi-AZ Design**: Creates subnets across 3 availability zones for high availability
- **Public & Private Subnets**: Sets up both public and private subnets for proper security segmentation
- **NAT Gateway**: Configures a NAT gateway for outbound internet access from private subnets
- **Internet Gateway**: Creates and attaches an Internet Gateway to the VPC
- **Managed Network ACLs**: Properly configured network ACLs and security groups

## Prerequisites

- AWS credentials with appropriate permissions
- Terraform installed (>= 1.0.0)

## Usage

1. Create your `terraform.tfvars` file in the current folder. You can refer to `terraform.tfvars.example` as a template:

   ```hcl
   aws_region  = "us-east-1"
   access_key  = "YOUR_ACCESS_KEY"
   secret_key  = "YOUR_SECRET_KEY"
   vpc_cidr    = "10.42.0.0/16"
   environment = "dev"
   ```

2. Initialize and apply Terraform:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the created VPC |
| public_subnet_ids | List of public subnet IDs |
| private_subnet_ids | List of private subnet IDs |

These outputs can be used by other Terraform modules, such as the ec2-jenkins module, to deploy resources within this VPC.

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | AWS region | string | us-east-1 | no |
| access_key | AWS access key | string | - | yes |
| secret_key | AWS secret key | string | - | yes |
| vpc_cidr | CIDR block for the VPC | string | 10.42.0.0/16 | no |
| environment | Deployment environment | string | dev | no |

## Technical Details

The VPC configuration:
- Uses the terraform-aws-modules/vpc/aws module
- Creates 3 public and 3 private subnets (one in each available AZ)
- Configures internet connectivity via Internet Gateway and NAT Gateway
- Enables DNS support
- Sets appropriate tags for resources
- Manages default network ACLs, route tables, and security groups

## Security Considerations

This module creates network infrastructure only. It does not create any security groups for specific applications. Application-specific security groups (like for Jenkins) should be created in the respective application modules that use this VPC.