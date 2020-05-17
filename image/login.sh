#!/usr/bin/env bash

echo "Fetching account ID..."
account_id=$(aws sts get-caller-identity --query '[Account]' --output text)

echo "Fetching bastion region..."
region=$(aws configure get region)

echo "Logging into ECR..."
aws ecr get-login-password \
  --region ${region} \
| docker login \
    --username AWS \
    --password-stdin ${account_id}.dkr.ecr.${region}.amazonaws.com
