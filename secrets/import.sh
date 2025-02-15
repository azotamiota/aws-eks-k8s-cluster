#!/bin/bash

for public_key in secrets/recipients/*.asc; do
   gpg --quiet --import "$public_key"
done