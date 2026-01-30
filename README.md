# 🏗️ AWS Infrastructure as Code (Terraform)

This repository contains the complete Terraform configuration to provision a secure, three-tier cloud environment on AWS. It uses **Remote State Management** to ensure infrastructure consistency and prevent state file conflicts.

## 🌟 Key Features

* **Remote Backend**: State management via AWS S3 (`s3backendforupgrad`) for state locking and durability.
* **Custom Networking**: VPC with public subnets, Internet Gateway, and optimized routing tables.
* **Security-First Approach**: Granular Security Groups for Jenkins (8080), Node.js (8081), and SSH (22).
* **Load Balancing**: Application Load Balancer (ALB) to manage and distribute incoming application traffic.
* **Private Registry**: Amazon ECR setup for secure and private Docker image storage.

## 📂 File Structure

* `provider.tf`: Configures AWS provider and the S3 Remote Backend.
* `vpc.tf`: Defines the network isolation and connectivity layer.
* `sec_grp.tf`: Implements firewall rules for the "Least Privilege" security model.
* `instances.tf`: Provisions the Jenkins Bastion host and the Application Host.
* `ecr.tf` & `iam_ecr.tf`: Sets up the private container registry and required IAM permissions.
* `alb.tf`: Configures the Load Balancer for high availability.

## 🚀 Deployment Guide

1. **Initialize the Backend**:
Download providers and sync with the S3 state bucket.
```bash
terraform init

```

2. **Review Execution Plan**:
Verify syntax and preview exactly what AWS will create.
```bash
terraform plan

```

3. **Provision Infrastructure**:
Deploy the resources to the us-east-1 region.
```bash
terraform apply -auto-approve

```

## 📊 Outputs & Connectivity

Once deployed, the following resources are available:

* **Jenkins Server**: Accessible via Public IP on port 8080.
* **Application Host**: Private node accessible via Jenkins Agent/SSH.
* **ECR URI**: The endpoint used for pushing Docker images in the CI/CD pipeline.

