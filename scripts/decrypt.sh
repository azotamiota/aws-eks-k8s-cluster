#!/bin/bash

gpg -r "Norbert Majer" --decrypt ./secrets/encrypted_secrets/terraform.tfvars.gpg > ./terraform/terraform.tfvars