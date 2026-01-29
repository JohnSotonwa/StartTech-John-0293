# StartTech Deployment Runbook

This runbook describes how the StartTech application and infrastructure operate, how they are deployed, and how to verify their health.

---

## 1. Infrastructure Provisioning

### Tool
- Terraform

### Process
1. Terraform initializes providers and backend.
2. Networking (VPC, subnets, routing) is created.
3. Compute layer (ALB, Auto Scaling Group, EC2) is provisioned.
4. Supporting services (Redis, S3, CloudFront, CloudWatch) are created.
5. Terraform outputs expose all required endpoints.

---

## 2. Backend Deployment

### CI/CD Flow
1. GitHub Actions runs Go linting and tests.
2. Docker image is built using a multi-stage Dockerfile.
3. Image is pushed to Amazon ECR.
4. EC2 instances pull the latest image from ECR.
5. Containers run behind the ALB.

### Verification
- Check target group health in EC2 → Target Groups.
- Ensure EC2 instances are **healthy**.
- Test backend via:
curl http://<ALB_DNS_NAME>


---

## 3. Frontend Deployment

### CI/CD Flow
1. React app is built using `npm run build`.
2. Static files are synced to S3.
3. CloudFront serves content globally.

### Verification
- Visit the CloudFront domain.
- Confirm frontend loads correctly.

---

## 4. Monitoring & Logs

- **CloudWatch Logs** capture backend application logs.
- **ALB Target Group Health Checks** ensure traffic only reaches healthy instances.

---

## 5. Common Issues & Resolution

### Backend shows `503 Service Unavailable`
- Check if target group has healthy instances.
- Confirm Docker container is running on EC2.
- Verify security group rules allow traffic from ALB.

### Frontend not loading
- Ensure React build exists before S3 sync.
- Confirm CloudFront distribution status is `Deployed`.

---

## 6. Access Control

- Assessors are provided with **read-only IAM credentials**.
- No write or delete permissions are granted.

---
