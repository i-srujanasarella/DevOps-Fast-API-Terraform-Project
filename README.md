# FastAPI Terraform DevOps Project

A FastAPI microservice deployed on AWS EC2 using Terraform, Docker, and GitHub Actions CI/CD.

## Project Structure.
├── environments/
│   ├── dev/
│   ├── qa/
│   └── prod/
├── modules/
│   └── infrastructure/
├── app/
│   ├── main.py
│   ├── Dockerfile
│   └── requirements.txt
├── variables.tf
└── .github/workflows/terraform.yml

## Environments
| Environment | Branch | CIDR |
|-------------|--------|------|
| Dev | dev | 10.0.0.0/16 |
| QA | qa | 10.1.0.0/16 |
| Prod | prod | 10.2.0.0/16 |

## Pipeline Flow
Push to dev → Deploy Dev
Push to qa → Deploy QA
Push to prod → Manual Approval → Deploy Prod → Manual Approval → Destroy

## Prerequisites
- AWS Account
- Terraform installed
- Docker installed
- GitHub Account

## GitHub Secrets Required
| Secret | Description |
|--------|-------------|
| AWS_ACCESS_KEY_ID | AWS Access Key |
| AWS_SECRET_ACCESS_KEY | AWS Secret Key |
| TF_VAR_KEY_NAME | EC2 Key Pair Name |

## Deployment Steps
1. Clone the repository
2. Add GitHub Secrets
3. Push to dev branch to trigger pipeline
4. Merge to qa branch to deploy to QA
5. Merge to prod branch for prod deployment with approval

## Accessing the Application
Once deployed, access the FastAPI app at:
http://<EC2_PUBLIC_IP>:8000
http://<EC2_PUBLIC_IP>:8000/health
http://<EC2_PUBLIC_IP>:8000/docs
