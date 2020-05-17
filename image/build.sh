  
#!/usr/bin/env bash

echo "Fetching account ID..."
account_id=$(aws sts get-caller-identity --query '[Account]' --output text)

echo "Fetching bastion region..."
region=$(aws configure get region)

echo "Building container..."
docker build -t ${account_id}.dkr.ecr.${region}.amazonaws.com/bastion .
