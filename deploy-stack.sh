#!/usr/bin/env bash

# Set these parameters based on your environment
BUCKET="bastion-lambdas"
CLUSTER_VPC_ID="vpc-xxxxxxxx"
CLUSTER_DEFAULT_SG_ID="sg-xxxxxxxx"
CLUSTER_SUBNET_IDS="subnet-xxxxxxxx,subnet-xxxxxxxx,subnet-xxxxxxxx"

aws cloudformation package \
    --template cloudformation/main.yml \
    --s3-bucket $BUCKET \
    --output-template-file packaged.yml > /dev/null

aws cloudformation deploy \
    --stack-name bastion \
    --template-file ./packaged.yml \
    --capabilities CAPABILITY_IAM \
    --parameter-overrides \
        ClusterVpcID=$CLUSTER_VPC_ID \
        ClusterDefaultSg=$CLUSTER_DEFAULT_SG_ID \
        ClusterSubnets=$CLUSTER_SUBNET_IDS
