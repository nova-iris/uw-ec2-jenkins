variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "access_key" {
  description = "AWS access key"
}

variable "secret_key" {
  description = "AWS secret key"
}

# EC2 instance variables
variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "jenkins-server"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "public_key" {
  description = "Public yey for SSH access"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the instance will be launched"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 20
}

variable "instance_state" {
  description = "State of the EC2 instance after creation"
  type        = string
  default     = "stopped"
}

# Jenkins variables
variable "init_admin_user" {
  description = "Initial admin user for Jenkins"
  type        = string
  default     = "admin"
}

variable "init_admin_password" {
  description = "Initial admin password for Jenkins"
  type        = string
  default     = "your_secure_password"
}

variable "jenkins_plugins" {
  description = "List of Jenkins plugins to install"
  type        = list(string)
  default = [
    "git",
    "git-client",
    "credentials",
    "credentials-binding",
    "cloudbees-folder",
    "workflow-job",
    "workflow-api",
    "workflow-cps",
    "workflow-multibranch",
    "workflow-basic-steps",
    "workflow-durable-task-step",
    "workflow-scm-step",
    "workflow-step-api",
    "workflow-support",
    "pipeline-groovy-lib",
    "pipeline-input-step",
    "pipeline-model-api",
    "pipeline-model-definition",
    "pipeline-model-extensions",
    "pipeline-stage-step",
    "pipeline-stage-tags-metadata",
    "scm-api",
    "ssh-credentials",
    "plain-credentials",
    "structs",
    "script-security",
    "matrix-project",
    "mailer",
    "ws-cleanup"
  ]
}

variable "jenkins_job_name" {
  description = "Name of the Jenkins job to create"
  type        = string
  default     = "demo-job"
}

variable "github_repo_url" {
  description = "GitHub repository URL for the Jenkins job"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch for the Jenkins job"
  type        = string
  default     = "*"
}
