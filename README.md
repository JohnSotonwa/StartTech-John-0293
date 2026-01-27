StartTech Application - README.md
# StartTech Full-Stack Application

This repository contains the **frontend (React)** and **backend (Golang)** code for the StartTech application. It is fully integrated with CI/CD pipelines that deploy the frontend to **S3 + CloudFront** and the backend as a **Docker container on EC2 instances** behind an **ALB**.

---

## **Repository Structure**



starttech-application/
├── .github/
│ └── workflows/
│ ├── frontend-ci-cd.yml
│ └── backend-ci-cd.yml
├── frontend/ # React frontend code
├── backend/ # Golang backend code
├── scripts/
│ ├── deploy-backend.sh
│ └── health-check.sh
└── README.md


---

## **Secrets Required in GitHub**

You must create the following **repository secrets** in GitHub:

| Secret Name              | Description |
|---------------------------|-------------|
| `AWS_ACCESS_KEY_ID`       | Your AWS IAM user's access key |
| `AWS_SECRET_ACCESS_KEY`   | Your AWS IAM user's secret key |
| `AWS_REGION`              | AWS region (e.g., `us-east-1`) |
| `ALB_DNS_NAME`            | DNS of the backend Application Load Balancer |
| `ECR_REPO`                | Backend Docker image ECR repository URL |
| `SSH_PRIVATE_KEY`         | Private key for connecting to EC2 instances (PEM content) |
| `S3_BUCKET_NAME`          | Frontend S3 bucket name |
| `CLOUDFRONT_DIST_ID`      | CloudFront distribution ID for the frontend |

> ⚠️ `SSH_PRIVATE_KEY` must contain the full private key text (including `-----BEGIN RSA PRIVATE KEY-----` and `-----END RSA PRIVATE KEY-----`) with proper line breaks.

---

## **Frontend Pipeline**

The **frontend CI/CD workflow** builds and deploys the React application:

1. Checkout the repository.
2. Install Node.js dependencies.
3. Run unit tests.
4. Build the production-ready React bundle.
5. Run `npm audit` for security scanning.
6. Deploy the build folder to the **S3 bucket**.
7. Invalidate **CloudFront cache** for immediate changes.

Trigger: `push` to the `main` branch.

---

## **Backend Pipeline**

The **backend CI/CD workflow** builds and deploys the Golang API:

1. Checkout the repository.
2. Run Go vet for code quality.
3. Build the backend Docker image.
4. Login to **ECR** using AWS credentials.
5. Tag and push the Docker image to ECR.
6. Deploy the image to all EC2 instances behind the **ALB** using `deploy-backend.sh`.
7. Run `health-check.sh` to ensure the backend is healthy.

Trigger: `push` to the `main` branch.

---

## **Scripts**

### **`deploy-backend.sh`**

- Deploys the latest Docker image to all EC2 instances behind the ALB.
- Uses AWS CLI to find instance IDs and public IPs.
- Uses SSH with the private key from GitHub secrets.
- Stops old container and runs the new image.

### **`health-check.sh`**

- Sends an HTTP request to the backend `/health` endpoint via ALB.
- Returns `✅` if status code is 200.
- Fails the workflow if status code is not 200.

---

## **Setting Up Locally**

1. Clone the repository:

```bash
git clone git@github.com:YourUsername/starttech-application.git
cd starttech-application


Ensure Node.js and Go are installed locally for testing.

Install frontend dependencies:

cd frontend
npm install


Build frontend locally:

npm run build


Run backend locally (for testing):

cd backend
go run main.go

Testing CI/CD Workflows

Make a change in either frontend/ or backend/.

Push to main branch:

git add .
git commit -m "Test CI/CD"
git push origin main


Check GitHub Actions → Workflow runs → see logs for success/failure.

Frontend should be live at: https://<CloudFrontDomain>/

Backend health can be checked at: http://<ALB_DNS_NAME>:8080/health

Notes

Backend Docker deployment requires SSH_PRIVATE_KEY to connect to EC2 instances.

Frontend deployment will overwrite the S3 bucket and invalidate CloudFront cache automatically.

CI/CD pipelines use only the GitHub secrets — no local environment setup needed for deployment.


