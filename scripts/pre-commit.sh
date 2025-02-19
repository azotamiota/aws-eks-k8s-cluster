#!/bin/bash

# set -eo pipefail

sudo apt-get update && sudo apt-get install -y pre-commit tflint
pre-commit run --all-files
