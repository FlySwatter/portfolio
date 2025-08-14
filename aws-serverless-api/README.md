# AWS Serverless API (Lambda + API Gateway + DynamoDB) — Terraform

A minimal CRUD "todo" API that runs on AWS Lambda behind API Gateway and stores items in DynamoDB.

## Contents
- `main.tf`, `variables.tf`, `outputs.tf`: Terraform to provision API Gateway, Lambda, and DynamoDB
- `lambda_function.py`: Python Lambda handler with CRUD operations
- `requirements.txt`: Python deps for Lambda (boto3 is available on AWS Lambda, left here for local dev)

## Quickstart
1. Install Terraform and AWS CLI. Configure credentials (`aws configure`).
2. `terraform init && terraform apply -auto-approve`
3. Terraform output shows the invoke URL.
4. Test:
   ```bash
   curl -X POST "$API_URL/todos" -d '{"id":"1","title":"demo"}' -H "Content-Type: application/json"
   curl "$API_URL/todos/1"
   ```

**NOTE:** This sample avoids secrets and uses basic IAM roles created by Terraform.
