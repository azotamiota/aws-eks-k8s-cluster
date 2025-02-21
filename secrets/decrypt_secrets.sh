#!/bin/bash

./secrets/import_gpg_keys.sh

decrypted_path="secrets/decrypted_secrets/"
mkdir -p ./secrets/decrypted_secrets
for path_to_secret in secrets/encrypted_secrets/*.encrypted; do
  encrypted_file=$(echo "$path_to_secret" | tr '/' ' ' | awk '{print $3}')
  basename="${encrypted_file%.encrypted}"
  echo "Decrypting secrets..."
  echo "Encrypted_file: $encrypted_file"
  gpg --batch --yes --quiet --output "./secrets/decrypted_secrets/$basename" --decrypt ./secrets/encrypted_secrets/$encrypted_file
  echo "Done."
done
