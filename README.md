# AWS EKS Cluster Infrastructure with Terraform

This repository provides a complete Infrastructure-as-Code (IaC) setup for provisioning an Amazon Elastic Kubernetes Service (EKS) cluster and its required resources using Terraform.
It includes secure management of secrets, automation through GitHub Actions, and utility scripts to simplify usage.

## Features
- Provision AWS EKS Clusters using Terraform

- Securely manage sensitive secrets using GPG-encrypted terraform.tfvars files

- Automated infrastructure deployment via GitHub Actions

- Scripts to decrypt secrets for use and re-encrypt updates securely

- Follows best practices for AWS EKS setup

# Repository Structure

```tree Midnight
aws-eks-k8s-cluster/
├── .github/
│   └── workflows/
│       └── deploy.yml       # GitHub Actions pipeline to deploy the infrastructure
├── README.md
├── scripts
│   ├── install_tfenv.sh
│   └── pre-commit.sh        # Code quality test
├── secrets
│   ├── decrypt_secrets.sh   # Decrypt terraform.tfvars & secrets for logging in to AWS Account
│   ├── encrypt_secrets.sh   # Update secrets and re-encrypt them
│   ├── encrypted_secrets
│   │   ├── azotamiota_admin_AWS_access.txt.encrypted
│   │   └── terraform.tfvars.encrypted
│   ├── import_gpg_keys.sh
│   └── recipients
│       ├── azotamiota-pubkey.asc
│       ├── github-actions-pubkey.asc
│       └── majern02-pubkey.asc
└── terraform
    ├── 00-provider.tf
    ├── 01-vpc.tf
    ├── 02-subnets.tf
    ├── 03-internet-gateway.tf
    ├── 04-backend-s3.tf
    ├── 05-backend-dynamodb.tf
    ├── 06-nat-gateway.tf
    ├── 07-routes.tf
    ├── 08-eks.tf
    ├── 08.1-eks.tf
    ├── 09-node.tf
    ├── 10-iam-oicd.tf
    ├── 11-iam-autoscaler.tf
    ├── outputs.tf
    ├── terraform.tfstate
    ├── terraform.tfstate.backup
    └── variables.tf
```

## Requirements
- Terraform

- GPG

- Access to the public key used for encryption

- AWS CLI (for local testing)

- terraform.tfvars.encrypted must be decrypted before running Terraform locally

## Secrets Management
Sensitive information regarding the infrastructure is securely stored in an encrypted terraform.tfvars.encrypted file as well as login credentials & private GPG keys

## Decrypt (Locally)
Run:
`./secrets/decrypt_secrets.sh `

## Encrypt (After Editing)
After editing terraform.tfvars and other secrets re-encrypt it.

Run:
`./secrets/encrypt_secrets.sh `

## AWS Resources Managed
This setup provisions:

- EKS Cluster

- Node Groups

- VPC/Subnets/Security Groups

- IAM Roles & Policies

- Any supporting infrastructure required by EKS

## Terraform Backend & State
The Terraform backend is configured and contains the remote state in a versioned S3 bucket. State locking is being used by a DynamoDB table. See the configuration in the `..-backend-....tf` files.

## Security Notice
Never commit plaintext terraform.tfvars to the repository. Use the provided `encrypt_secrets.sh` to secure updated secrets. Review GitHub Actions access to ensure private key material is used only for automation.

## Future features

Current Terraform resources provision the infrastructure by utilising predifined Terraform modules. Other Terraform files with commented out resources are going to be used for a more granular infrastructure in the future. Utilising this solution is currently under development.
