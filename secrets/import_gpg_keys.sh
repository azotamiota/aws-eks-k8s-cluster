#!/bin/bash

echo "Importing all keys..."
for public_key in secrets/recipients/*.asc; do
   gpg --quiet --import "$public_key"
done
echo "All GPG keys imported successfully"
