# Infrastructure as Code: AWS Provisioning with Terraform

This repository contains the Terraform configuration files used to provision the infrastructure for the Upgrad Node.js application.

## 🏗️ Resources Managed
- **VPC & Subnets**: Custom networking for isolation.
- **Security Groups**: Firewall rules for Jenkins (8080) and App Host (8081).
- **EC2 Instances**: Jenkins Bastion Server and Application Host.
- **ECR**: Private Docker Registry.
- **ALB**: Application Load Balancer.

## 🚀 Usage
1. Initialize: `terraform init`
2. Plan: `terraform plan`
3. Deploy: `terraform apply`
