#!/bin/bash

./secrets/import_gpg_keys.sh

users=$(for i in secrets/recipients/*.asc ; do gpg --import --keyid-format 0xlong --import-options show-only --quiet "${i}" | perl -nle 's/^\s*//g; print unless /^(pub|uid|sub)/;' ; done)

recipients=""
for recipient in $users; do
  recipients="${recipients} --recipient ${recipient} "
done

encrypted_path="secrets/encrypted_secrets/"
for path_to_secret in secrets/decrypted_secrets/*; do
  secret_file=$(echo "$path_to_secret" | tr '/' ' ' | awk '{print $3}')
  echo "Encrypting secrets..."
  echo "secret_file: $secret_file"
  gpg --batch --yes --always-trust --output "$encrypted_path${secret_file}.encrypted" ${recipients} --encrypt ./secrets/decrypted_secrets/$secret_file
  echo "Done."
done
