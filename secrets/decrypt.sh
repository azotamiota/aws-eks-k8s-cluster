#!/bin/bash

./secrets/import.sh

gpg --batch --yes --output "./terraform/terraform.tfvars" --decrypt ./secrets/encrypted_secrets/terraform.tfvars.encrypted
# gpg -r "Norbert Majer" -r "Norbert Majer 2" --decrypt ./secrets/encrypted_secrets/terraform.tfvars.gpg > ./terraform/terraform.tfvars