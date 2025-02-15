#!/bin/bash
gpg -r "Norbert Majer" -r "Norbert Majer 2" --encrypt ./terraform/terraform.tfvars
mv ./terraform/terraform.tfvars.gpg ./secrets/encrypted_secrets/