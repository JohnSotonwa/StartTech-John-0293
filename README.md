# StartTech Full-Stack Infrastructure & Application Deployment

This repository contains the infrastructure and application setup for the StartTech full-stack project.  
The solution demonstrates a production-style deployment on AWS using Terraform, Docker, GitHub Actions, and managed AWS services.

---

## 🔧 Technology Stack

### Infrastructure
- **Terraform** – Infrastructure as Code
- **AWS VPC** – Custom networking with public and private subnets
- **EC2 Auto Scaling Group** – Backend compute
- **Application Load Balancer (ALB)** – Traffic distribution
- **Amazon ElastiCache (Redis)** – Caching/session storage
- **Amazon S3** – Frontend static hosting
- **Amazon CloudFront** – CDN for frontend
- **Amazon ECR** – Docker image registry
- **Amazon CloudWatch** – Logging and monitoring

### Application
- **Backend:** Golang REST API (Dockerized)
- **Frontend:** React (static build)
- **CI/CD:** GitHub Actions

---

## 📁 Repository Structure

.
├── backend/
│ └── MuchToDo/ # Go application (go.mod located here)
├── frontend/ # React application
├── terraform/ # Infrastructure code
├── scripts/ # Deployment scripts
├── .github/workflows/ # CI/CD pipelines
├── README.md
└── RUNBOOK.md


---

## 🚀 Deployment Overview

### Infrastructure Deployment
- Infrastructure is provisioned using Terraform.
- Resources include VPC, subnets, ALB, EC2 Auto Scaling Group, Redis, S3, CloudFront, and CloudWatch.
- Outputs expose key endpoints such as:
  - ALB DNS Name
  - CloudFront domain
  - Redis endpoint

### Application Deployment
- Backend is built as a Docker image and pushed to Amazon ECR.
- EC2 instances pull the image and run containers behind an ALB.
- Frontend is built and synced to S3, then served globally via CloudFront.

---

## 🌐 Access Points

- **Backend API:**  
  Accessible via the ALB DNS name.

- **Frontend Application:**  
  Accessible via the CloudFront domain.

---

## 🔐 Security Notes

- No AWS credentials are committed to this repository.
- GitHub Secrets are used for all sensitive values.
- IAM permissions follow least-privilege principles.

---

## 📌 Notes for Assessors

- This repository is intended for **view-only evaluation**.
- All infrastructure and application components can be inspected via the AWS Console using read-only IAM permissions.
- No manual intervention is required to validate the deployment.

---
