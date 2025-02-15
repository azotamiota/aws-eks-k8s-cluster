#!/bin/bash

for public_key in secrets/users/*.asc; do
  echo "ehune: $public_key"
done