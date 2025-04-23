# uw-ec2-jenkins
Upwork task from Chandan Kumar to install Jenkins in EC2

Initialize Terraform:

bash
Copy
Edit
terraform init
Plan the Deployment:

bash
Copy
Edit
terraform plan -var-file="terraform.tfvars"
Apply the Configuration:

bash
Copy
Edit
terraform apply -var-file="terraform.tfvars"
Access Jenkins:

Once the instance is up, navigate to http://<jenkins_public_ip>:8080 in your browser.

Shutdown and Restart:

You can stop and start the EC2 instance via the AWS Console or CLI. Jenkins will retain its configuration across these operations.