#!/bin/bash

./secrets/import.sh

echo "Decrypting secrets..."
gpg --batch --yes --quiet --output "./terraform/terraform.tfvars" --decrypt ./secrets/encrypted_secrets/terraform.tfvars.encrypted
echo "Done."
