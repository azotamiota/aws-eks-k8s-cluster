#!/bin/bash

./secrets/import.sh

gpg --batch --yes --output "./terraform/terraform.tfvars" --decrypt ./secrets/encrypted_secrets/terraform.tfvars.encrypted
mkdir -p decrypted_scripts
gpg --batch --yes --output "./decrypted_scripts/export_keys.sh" --decrypt ./secrets/encrypted_secrets/export_keys.sh.encrypted