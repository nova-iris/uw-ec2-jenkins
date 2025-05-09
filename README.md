# Jenkins EC2 Infrastructure

This Terraform configuration provisions a Jenkins server on AWS EC2. The server will be automatically configured with initial admin credentials and a demo pipeline job.

## Project Structure

This project consists of two main modules:

1. **vpc-jenkins**: Creates the VPC infrastructure required for the Jenkins server.
2. **ec2-jenkins**: Provisions and configures the Jenkins server on AWS EC2.

## Getting Started

For detailed instructions on setting up and using each module, please refer to their respective README files:

- [EC2 Jenkins Module Documentation](./ec2-jenkins/README.md)
- [VPC Jenkins Module Documentation](./vpc-jenkins/README.md) (if available)

Follow the instructions in each module's documentation to properly configure and deploy the infrastructure.
