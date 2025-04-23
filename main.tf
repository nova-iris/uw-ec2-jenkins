# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Get all subnets in the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "availability-zone"
    values = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1f"] # Supported AZs from error message
  }
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "${var.instance_name}-key"
  public_key = file("${var.public_key}")
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH, HTTP, and Jenkins"
  vpc_id      = data.aws_vpc.default.id #var.vpc_id #TODO

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Consider locking this down later #TODO
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
    cidr_blocks = ["0.0.0.0/0"] # If internal only, change this to VPC CIDR #TODO
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

module "jenkins_server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 4.3.0"

  name = var.instance_name

  ami                    = "ami-084568db4383264d4" # data.aws_ami.ubuntu_24_04.id #" #TODO
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ec2_key.key_name
  subnet_id              = tolist(data.aws_subnets.default.ids)[0] #var.subnet_id #TODO
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  associate_public_ip_address = true

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
  })

  tags = {
    Environment = var.environment
    Project     = "Jenkins"
  }
}



