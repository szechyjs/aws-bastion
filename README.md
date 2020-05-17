# AWS Bastion

This work is largely based on [jdhollis/bastions-on-demand](https://github.com/jdhollis/bastions-on-demand).
I'm not a big fan of Terraform or Clojure so I rewrote it using Cloudformation and ruby.

## Setup
1. Create a S3 bucket for storing lambda code. Create this however you want.
1. Update the variables in `deploy-stack.sh`
    - `BUCKET`: the name of the bucket created in the previous step
    - `CLUSTER_VPC_ID`: the VPC that the basion should belong to
    - `CLUSTER_DEFAULT_SG_ID`: the default SG ID for the VPC
    - `CLUSTER_SUBNET_IDS`: a comma separated list of subnets IDS
1. Run `./deploy-stack.sh` to create/update the Cloudformation stack
1. Build and push the bastion image to ECR
    - `cd image`
    - `./login.sh`
    - `./build.sh`
    - `./push.sh`

## Using
*CLI tool coming soon*

### Creating
- Send a signed `POST` request to the `ApiUrl` in the Cloudformation output.
- `ssh ops@ip-from-create-response`
- *Note:* Ensure you have added your SSH public key to your AWS user account.
s
### Destroying
- Send a signed `DELETE` request to the `ApiUrl` in the Cloudformation output.
