#!/bin/bash

./secrets/import.sh

gpg --batch --yes --output "./terraform/terraform.tfvars" --decrypt ./secrets/encrypted_secrets/terraform.tfvars.encrypted