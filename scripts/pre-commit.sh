#!/bin/bash

# set -eo pipefail

sudo apt-get update && sudo apt-get install -y pre-commit
pre-commit run --all-files
