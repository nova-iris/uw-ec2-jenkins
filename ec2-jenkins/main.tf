terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
}

module "ami_ubuntu_24_04_latest" {
  source = "github.com/andreswebs/terraform-aws-ami-ubuntu"
}

locals {
  ami_id = module.ami_ubuntu_24_04_latest.ami_id
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH, HTTP, and Jenkins"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
    Project     = "Jenkins"
  }
}

resource "aws_key_pair" "ec2_key" {
  count      = var.public_key != "" ? 1 : 0
  key_name   = "${var.instance_name}-key"
  public_key = file("${var.public_key}")
}

module "jenkins_server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 4.3.0"

  name = var.instance_name

  ami                    = local.ami_id
  instance_type          = var.instance_type
  key_name               = var.public_key != "" ? aws_key_pair.ec2_key[0].key_name : null
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  associate_public_ip_address = var.associate_public_ip_address

  root_block_device = [
    {
      volume_size           = var.volume_size
      volume_type           = "gp2"
      delete_on_termination = false
    }
  ]

  user_data = templatefile("${path.module}/scripts/user_data.sh.tftpl", {
    admin_user       = var.init_admin_user
    admin_password   = var.init_admin_password
    github_repo_url  = var.github_repo_url
    github_branch    = var.github_branch
    jenkins_job_name = var.jenkins_job_name
    jenkins_plugins  = join(" ", var.jenkins_plugins)
    enable_public_ip = var.associate_public_ip_address
  })

  tags = {
    Environment = var.environment
    Project     = "Jenkins"
  }
}

resource "time_sleep" "wait_5_mins" {
  depends_on      = [module.jenkins_server]
  create_duration = "5m"
}

resource "aws_ec2_instance_state" "this" {
  instance_id = module.jenkins_server.id
  state       = var.instance_state
  depends_on  = [time_sleep.wait_5_mins]
}
