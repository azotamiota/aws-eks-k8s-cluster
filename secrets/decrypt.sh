#!/bin/bash
gpg -r "Norbert Majer" -r "Norbert Majer 2" --decrypt ./secrets/encrypted_secrets/terraform.tfvars.gpg > ./terraform/terraform.tfvars