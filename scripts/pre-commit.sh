#!/bin/bash

# set -eo pipefail

sudo apt-get update && sudo apt-get install -y pre-commit > /dev/null
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
pre-commit run --all-files
