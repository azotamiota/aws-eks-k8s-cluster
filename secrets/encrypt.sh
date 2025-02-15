#!/bin/bash

./secrets/import.sh

users=$(for i in secrets/recipients/*.asc ; do gpg --keyid-format 0xlong --import-options show-only "${i}" | perl -nle 's/^\s*//g; print unless /^(pub|uid|sub)/;' ; done)

recipients=""
for recipient in $users; do
  recipients="${recipients} --recipient ${recipient} "
done

gpg --batch --yes --always-trust --output "secrets/encrypted_secrets/terraform.tfvars.encrypted" ${recipients} --encrypt ./terraform/terraform.tfvars

# gpg -r "Norbert Majer" -r "Norbert Majer 2" --encrypt ./terraform/terraform.tfvars
# mv ./terraform/terraform.tfvars.gpg ./secrets/encrypted_secrets/