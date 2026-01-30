# AWS Infrastructure as Code (Terraform)

This is the secure bedrock for our CI/CD + Node.js deployment. Creates an isolated, production-grade environment with proper networking, state management, and scalability baked in from day one.

## Why This Design
**Security First**: Custom VPC keeps everything private except essential ports. S3 remote state prevents drift and enables team collaboration.  
**Scalable**: ALB + ECR ready for growth. Subnets positioned for future private deployments.  
**Zero Friction**: Outputs feed directly into Jenkins/Ansible—no manual hunting.

## What Gets Created
- **VPC + Networking**: Public subnets + IGW for Jenkins/app access  
- **State Backend**: s3backendforupgrad bucket (handles locking/versioning)  
- **EC2 Instances**: Jenkins master + Docker app host (ubuntu/upgrad-key)  
- **Security Groups**: SSH(22), Jenkins(8080), App(8081)—nothing else  
- **ECR Repo**: Private registry for our Node.js Docker images  
- **ALB**: Single DNS entry point w/ target group on 8081  

## File Breakdown
provider.tf - Connects Terraform to AWS and sets up the S3 backend  
vpc.tf + sec_grp.tf - Network isolation + firewall rules  
instances.tf - Server provisioning  
ecr.tf & iam_ecr.tf: Sets up the private registry and the IAM instance profiles that allow our servers to securely push/pull Docker images without needing hardcoded AWS keys
alb.tf - Traffic distribution  

## Deploy Sequence
```bash
terraform init    # Hooks up S3 backend
terraform plan    # Dry run preview
terraform apply   # Live deployment
```
